CREATE TABLE personas (
    nombre TEXT,
    edad INTEGER,
    calle TEXT,
    ciudad TEXT,
    provincia TEXT,
    cp VARCHAR(10),
    longitud DOUBLE PRECISION,
    latitud DOUBLE PRECISION
);


CREATE TABLE personas_columnar (
    nombre TEXT,
    edad INTEGER,
    calle TEXT,
    ciudad TEXT,
    provincia TEXT,
    cp VARCHAR(10),
    longitud DOUBLE PRECISION,
    latitud DOUBLE PRECISION
) using columnar;