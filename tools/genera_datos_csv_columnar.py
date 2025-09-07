from faker import Faker
import csv

fake = Faker('es_ES')  # Locale en español
num_rows = 1000000000     # Número de filas deseado

header = [
    'nombre',
    'edad',
    'calle',
    'ciudad',
    'provincia',
    'cp',
    'longitud',
    'latitud'
]

with open('datos_fake.csv', 'w', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)
    writer.writerow(header)
    for _ in range(num_rows):
        writer.writerow([
            fake.name(),
            fake.random_int(min=18, max=80),
            fake.street_address(),
            fake.city(),
            fake.state(),
            fake.postcode(),
            fake.longitude(),
            fake.latitude()
        ])
