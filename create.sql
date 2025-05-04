CREATE TABLE your_table_name (
    id BIGINT,
    account BIGINT,
    time VARCHAR,
    purchase VARCHAR,
    comment VARCHAR,
    tax_amount DOUBLE PRECISION
);

drop table output_seatunnel;

CREATE TABLE output_seatunnel (
    id BIGINT,
    account BIGINT,
    time VARCHAR,
    purchase VARCHAR,
    comment VARCHAR,
    tax_amount DOUBLE PRECISION
);
