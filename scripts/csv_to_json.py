import csv
import json
import base64

csv_file_path = 'input.csv'

with open(csv_file_path, mode='r', encoding='utf-8') as file:
    csv_reader = csv.DictReader(file)

    json_data = []

    for idx, row in enumerate(csv_reader):
        json_object = {
            "id": idx + 1,
            "descriptions": {
                "en": row["English"],
                "fr": row["French"],
                "de": row["German"]
            },
            "category": row["Category"],
            "type": row["Type"],
            "timer": int(row["Timer"]),
            "suitableForMan": bool(int(row["For Men"])),
            "suitableForWoman": bool(int(row["For Women"])),
            "suitableForOther": bool(int(row["For Others"]))
        }

        json_data.append(json_object)

json_string = json.dumps(json_data, indent=2)

encoded_json = base64.b64encode(json_string.encode('utf-8')).decode('utf-8')

with open('../assets/challenges/challenges.txt', 'w', encoding='utf-8') as output_file:
    output_file.write(encoded_json)

if __name__ == "__main__":
    pass