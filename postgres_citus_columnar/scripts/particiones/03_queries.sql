
-- ¢omprobar datos diferentes en distintas particiones
select count(id) from ventas_2020 v 
union
select count(id) from ventas_2021 v2 

-- Convertir en columnar la partición de ventas_2020
SELECT alter_table_set_access_method('ventas_2020', 'columnar');

-- Intentar actualizar una entrada en la partición columnar
UPDATE ventas_2020
SET cliente = 'Manuel de la Rosa'
WHERE id = 147;

UPDATE ventas
SET cliente = 'Manuel de la Rosa'
WHERE id = 280;

UPDATE ventas_2021
SET cliente = 'Manuel de la Rosa'
WHERE id = 280;

select * from ventas where id = 280;

-- Cambiar partición a heap
SELECT alter_table_set_access_method('ventas_2020', 'heap');

-- Probar a actualizar de nuveo
UPDATE ventas_2020
SET cliente = 'Manuel de la Rosa'
WHERE id = 147;