CREATE TABLE your_table_name (
    id BIGINT,
    account BIGINT,
    time TIMESTAMP,
    purchase DATE,
    comment VARCHAR,
    tax_amount DOUBLE PRECISION
);

CREATE TABLE output_seatunnel (
    id BIGINT,
    account BIGINT,
    time TIMESTAMP,
    purchase DATE,
    comment VARCHAR,
    tax_amount DOUBLE PRECISION
);
