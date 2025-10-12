import csv
from faker import Faker
import random

# Crear instancia de Faker en español
fake = Faker("es_ES")

# Provincias españolas (puedes ampliarla según necesites)
provincias = [
    "Madrid", "Barcelona", "Valencia", "Sevilla", "Zaragoza",
    "Málaga", "Murcia", "Bilbao", "Valladolid", "A Coruña"
]

# Número de registros a generar
NUM_REGISTROS = 1000

# Nombre del archivo CSV de salida
output_file = "empleados.csv"

# Campos que tendrá la tabla
campos = [
    "id",
    "nombre",
    "apellidos",
    "dni",
    "email",
    "telefono",
    "direccion",
    "provincia",
    "salario"
]

# Generar datos y escribir a CSV
with open(output_file, mode="w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=campos)
    writer.writeheader()

    for i in range(1, NUM_REGISTROS + 1):
        nombre = fake.first_name()
        apellidos = fake.last_name() + " " + fake.last_name()
        dni = fake.bothify(text="########?")  # Ej: 12345678A
        email = fake.email()
        telefono = fake.phone_number()
        direccion = fake.street_address()
        provincia = random.choice(provincias)
        salario = round(random.uniform(22000, 80000), 2)

        writer.writerow({
            "id": i,
            "nombre": nombre,
            "apellidos": apellidos,
            "dni": dni,
            "email": email,
            "telefono": telefono,
            "direccion": direccion,
            "provincia": provincia,
            "salario": salario
        })

print(f"✅ Archivo CSV generado correctamente: {output_file}")
