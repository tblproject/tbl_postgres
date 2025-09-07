COPY personas
FROM '/DATASETS/datos_fake.csv'
DELIMITER ','
CSV HEADER;


COPY personas_columnar
FROM '/DATASETS/datos_fake.csv'
DELIMITER ','
CSV HEADER;