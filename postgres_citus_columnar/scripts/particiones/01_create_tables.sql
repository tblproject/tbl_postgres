-- Tabla padre particionada
CREATE TABLE ventas (
    id SERIAL,
    cliente VARCHAR(100) NOT NULL,
    producto VARCHAR(100) NOT NULL,
    monto NUMERIC(10,2) NOT NULL,
    fecha_venta DATE NOT NULL,
    CONSTRAINT ventas_pk PRIMARY KEY (id, fecha_venta)
) PARTITION BY RANGE (fecha_venta);

-- Particiones por año
CREATE TABLE ventas_2020 PARTITION OF ventas
    FOR VALUES FROM ('2020-01-01') TO ('2021-01-01');

CREATE TABLE ventas_2021 PARTITION OF ventas
    FOR VALUES FROM ('2021-01-01') TO ('2022-01-01');

CREATE TABLE ventas_2022 PARTITION OF ventas
    FOR VALUES FROM ('2022-01-01') TO ('2023-01-01');

CREATE TABLE ventas_2023 PARTITION OF ventas
    FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');

CREATE TABLE ventas_2024 PARTITION OF ventas
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

CREATE TABLE ventas_2025 PARTITION OF ventas
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

-- Consulta para ver las particiones generadas
SELECT inhrelid::regclass AS partition_name
    FROM pg_inherits
    WHERE inhparent = 'ventas'::regclass;