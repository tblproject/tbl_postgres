COPY ventas(cliente, producto, monto, fecha_venta)
FROM '/DATASETS/ventas_sinteticas.csv'
DELIMITER ','
CSV HEADER;

