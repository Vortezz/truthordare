import base64
import csv
import json

csv_file_path = 'input.csv'

with open(csv_file_path, mode='r', encoding='utf-8') as file:
    csv_reader = csv.DictReader(file)

    json_data = []

    for idx, row in enumerate(csv_reader):
        suitableFor = []

        if bool(int(row["For Men"])):
            suitableFor += [0]
        if bool(int(row["For Women"])):
            suitableFor += [1]
        if bool(int(row["For Others"])):
            suitableFor += [2]

        interestedBy = []

        if bool(int(row["Interested Men"])):
            interestedBy += [0]
        if bool(int(row["Interested Women"])):
            interestedBy += [1]
        if bool(int(row["Interested Others"])):
            interestedBy += [2]

        json_object = {
            "id": idx + 1,
            "descriptions": {
                "en": row["English"],
                "fr": row["French"]
            },
            "category": row["Category"],
            "type": row["Type"],
            "timer": int(row["Timer"]),
            "suitableFor": suitableFor,
            "interestedBy": interestedBy,
            "isSexual": bool(row["Sexual"]),
        }

        json_data.append(json_object)

json_string = json.dumps(json_data, indent=2)

encoded_json = base64.b64encode(json_string.encode('utf-8')).decode('utf-8')

with open('../assets/challenges/challenges.txt', 'w', encoding='utf-8') as output_file:
    output_file.write(encoded_json)

if __name__ == "__main__":
    pass
