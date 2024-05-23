#install faker to generate random data 
pip install Faker

#import required Libraries
import csv
from faker import Faker
import os

fake = Faker()

# Define the number of entries for each table
num_entries = 20

# Ensure the output directory exists
output_dir = 'c:\\Users\\anjal\\Downloads'
os.makedirs(output_dir, exist_ok=True)

# Function to write data to CSV
def write_csv(filename, headers, data):
    with open(os.path.join(output_dir, filename), 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(headers)
        writer.writerows(data)

# Generate data for Address table
address_data = [[i, fake.street_address(), fake.city(), fake.state_abbr(), fake.zipcode()] for i in range(1, num_entries + 1)]
write_csv('Address.csv', ['AddressID', 'Street', 'City', 'State', 'ZipCode'], address_data)

# Generate data for Patient table
#patient_data = [[i, i, fake.first_name(), fake.last_name(), fake.email(), fake.phone_number(), fake.boolean()] for i in range(1, num_entries + 1)]
#write_csv('Patient.csv', ['PatientID', 'AddressID', 'FirstName', 'LastName', 'Email', 'ContactNumber', 'PreviousPurchase'], patient_data)

patient_data = [[i, i, fake.first_name(), fake.last_name(), fake.email(), fake.phone_number(), fake.random_int(min=0, max=1), fake.date()] for i in range(1, num_entries + 1)]
write_csv('Patient.csv', ['PatientID', 'AddressID', 'FirstName', 'LastName', 'Email', 'ContactNumber', 'PreviousPurchase', 'BirthDate'], patient_data)

# Generate data for Physician table
physician_data = [[i, fake.name(), fake.job(), fake.phone_number(), fake.company()] for i in range(1, num_entries + 1)]
write_csv('Physician.csv', ['PhysicianID', 'Name', 'Specialty', 'PhoneNumber', 'VisitingHospital'], physician_data)

# Generate data for Prescription table
prescription_data = [[i, fake.random_int(min=1, max=num_entries), fake.random_int(min=1, max=num_entries), fake.date(), fake.sentence()] for i in range(1, num_entries + 1)]
write_csv('Prescription.csv', ['PrescriptionID', 'PatientID', 'PhysicianID', 'DateIssued', 'Dosage'], prescription_data)

# Generate data for MedicationItem table
medication_item_data = [[i, fake.catch_phrase(), fake.text(max_nb_chars=100), fake.text(max_nb_chars=50), fake.future_date()] for i in range(1, num_entries + 1)]
write_csv('MedicationItem.csv', ['MedicationItemID', 'Name', 'Description', 'SideEffects', 'ExpiryDate'], medication_item_data)

# Generate data for Pharmacy table
pharmacy_data = [[i, fake.company(), fake.street_address(), fake.city(), fake.state_abbr(), fake.zipcode(), fake.phone_number()] for i in range(1, num_entries + 1)]
write_csv('Pharmacy.csv', ['PharmacyID', 'ShopName', 'ShopStreet', 'ShopCity', 'ShopState', 'ShopZipCode', 'PhoneNumber'], pharmacy_data)

# Generate data for Inventory table
inventory_data = [[i, fake.random_int(min=1, max=num_entries), fake.random_int(min=1, max=num_entries), fake.random_int(min=0, max=100)] for i in range(1, num_entries + 1)]
write_csv('Inventory.csv', ['InventoryID', 'PharmacyID', 'MedicationItemID', 'Quantity'], inventory_data)

# Generate data for Order table
order_data = [[i, fake.random_int(min=1, max=num_entries), fake.random_int(min=1, max=num_entries), fake.date_this_decade(), fake.date_this_decade(), fake.random_number(digits=5)] for i in range(1, num_entries + 1)]
write_csv('Order.csv', ['OrderID', 'PharmacyID', 'PrescriptionID', 'OrderDate', 'DeliveryDate', 'TotalPrice'], order_data)


def generate_order_item_data(num_rows, order_ids, medication_item_ids):
    return [[i, fake.random_element(elements=order_ids), fake.random_element(elements=medication_item_ids), fake.random_int(min=1, max=5), fake.sentence()] for i in range(1, num_rows + 1)]

def generate_delivery_person_data(num_rows):
    return [[i, fake.first_name(), fake.last_name(), fake.email(), fake.phone_number()] for i in range(1, num_rows + 1)]

def generate_delivery_data(num_rows, order_ids, delivery_person_ids):
    return [[i, fake.random_element(elements=order_ids), fake.random_element(elements=delivery_person_ids), fake.date_this_decade(), fake.date_this_decade()] for i in range(1, num_rows + 1)]

def generate_supplier_data(num_rows):
    return [[i, fake.first_name(), fake.last_name(), fake.phone_number(), fake.email(), fake.street_address(), fake.city(), fake.state_abbr(), fake.zipcode()] for i in range(1, num_rows + 1)]

def generate_supply_record_data(num_rows, supplier_ids, pharmacy_ids, medication_item_ids):
    return [[i, fake.random_element(elements=supplier_ids), fake.random_element(elements=pharmacy_ids), fake.random_element(elements=medication_item_ids), fake.date_this_decade(), fake.random_int(min=1, max=100)] for i in range(1, num_rows + 1)]

def generate_transaction_data(num_rows, order_ids):
    return [[i, fake.random_element(elements=order_ids), fake.random_number(digits=5), fake.date_this_decade(), fake.random_element(elements=['Credit Card', 'Debit Card', 'Cash'])] for i in range(1, num_rows + 1)]
