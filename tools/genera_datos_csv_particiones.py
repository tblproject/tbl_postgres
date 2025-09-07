import csv
import random
from faker import Faker
from datetime import datetime

# Inicializar faker
faker = Faker("es_ES")

# Cantidad de registros a generar
N = 10000  

# Rango de fechas
start_date = datetime(2020, 1, 1)
end_date = datetime(2025, 12, 31)

# Archivo de salida
output_file = "ventas_sinteticas.csv"

# Posibles productos
productos = ["Laptop", "Smartphone", "Tablet", "Auriculares", "Monitor", "Teclado", "Mouse"]

# Generar datos
with open(output_file, mode="w", newline="", encoding="utf-8") as file:
    writer = csv.writer(file)
    # Escribir cabecera
    writer.writerow(["cliente", "producto", "monto", "fecha_venta"])
    
    for _ in range(N):
        cliente = faker.name()
        producto = random.choice(productos)
        monto = round(random.uniform(50, 2000), 2)
        fecha_venta = faker.date_between(start_date=start_date, end_date=end_date)
        
        writer.writerow([cliente, producto, monto, fecha_venta])

