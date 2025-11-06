package org.embulk.filter.dummy;

import org.embulk.config.Config;
import org.embulk.config.ConfigDefault;
import org.embulk.config.ConfigSource;
import org.embulk.config.Task;
import org.embulk.config.TaskSource;
import org.embulk.spi.Column;
import org.embulk.spi.Exec;
import org.embulk.spi.FilterPlugin;
import org.embulk.spi.Page;
import org.embulk.spi.PageBuilder;
import org.embulk.spi.PageOutput;
import org.embulk.spi.PageReader;
import org.embulk.spi.Schema;

/**
 * Dummy Filter Plugin for Embulk
 * This is a sample filter plugin that adds a suffix to all string columns.
 */
public class DummyFilterPlugin implements FilterPlugin {

    public interface PluginTask extends Task {
        @Config("message")
        @ConfigDefault("\"Dummy filter applied\"")
        String getMessage();
        
        @Config("suffix")
        @ConfigDefault("\"_dummy\"")
        String getSuffix();
    }

    @Override
    public void transaction(ConfigSource config, Schema inputSchema,
            FilterPlugin.Control control) {
        PluginTask task = config.loadConfig(PluginTask.class);
        
        // Log the message from configuration
        Exec.getLogger(DummyFilterPlugin.class).info("Dummy Filter Plugin: {}", task.getMessage());
        
        // Pass through the input schema without modification
        Schema outputSchema = inputSchema;
        
        control.run(task.dump(), outputSchema);
    }

    @Override
    public PageOutput open(TaskSource taskSource, Schema inputSchema,
            Schema outputSchema, PageOutput output) {
        PluginTask task = taskSource.loadTask(PluginTask.class);
        
        return new DummyPageOutput(task, inputSchema, outputSchema, output);
    }

    public static class DummyPageOutput implements PageOutput {
        private final PluginTask task;
        private final PageReader pageReader;
        private final PageBuilder pageBuilder;

        public DummyPageOutput(PluginTask task, Schema inputSchema, Schema outputSchema, PageOutput output) {
            this.task = task;
            this.pageReader = new PageReader(inputSchema);
            this.pageBuilder = new PageBuilder(Exec.getBufferAllocator(), outputSchema, output);
        }

        @Override
        public void add(Page page) {
            pageReader.setPage(page);
            
            while (pageReader.nextRecord()) {
                // Copy all columns from input to output
                for (Column column : pageReader.getSchema().getColumns()) {
                    if (pageReader.isNull(column)) {
                        pageBuilder.setNull(column);
                    } else {
                        switch (column.getType().getName()) {
                            case "boolean":
                                pageBuilder.setBoolean(column, pageReader.getBoolean(column));
                                break;
                            case "long":
                                pageBuilder.setLong(column, pageReader.getLong(column));
                                break;
                            case "double":
                                pageBuilder.setDouble(column, pageReader.getDouble(column));
                                break;
                            case "string":
                                // Add suffix to string values
                                String originalValue = pageReader.getString(column);
                                String modifiedValue = originalValue + task.getSuffix();
                                pageBuilder.setString(column, modifiedValue);
                                break;
                            case "timestamp":
                                pageBuilder.setTimestamp(column, pageReader.getTimestamp(column));
                                break;
                            case "json":
                                pageBuilder.setJson(column, pageReader.getJson(column));
                                break;
                            default:
                                throw new RuntimeException("Unsupported type: " + column.getType());
                        }
                    }
                }
                pageBuilder.addRecord();
            }
        }

        @Override
        public void finish() {
            pageBuilder.finish();
        }

        @Override
        public void close() {
            pageBuilder.close();
        }
    }
}
