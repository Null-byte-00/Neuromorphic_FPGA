import csv
import torch
from torch.utils.data import Dataset, DataLoader


class DirectionDataset(Dataset):
    def __init__(self, csv_path):
        self.samples = []

        with open(csv_path, newline="", encoding="utf-8") as file:
            reader = csv.DictReader(file)

            for row in reader:
                sequence = [
                    [
                        float(row[f"t{timestep}_i{input_index}"])
                        for input_index in range(1, 6)
                    ]
                    for timestep in range(1, 6)
                ]

                label = 0 if row["label"] == "lr" else 1

                self.samples.append(
                    (
                        torch.tensor(sequence, dtype=torch.float32),
                        torch.tensor(label, dtype=torch.long),
                    )
                )

    def __len__(self):
        return len(self.samples)

    def __getitem__(self, index):
        inputs, label = self.samples[index]
        return inputs, label


dataset = DirectionDataset("data/lr_rl_5inputs_5timesteps.csv")

loader = DataLoader(
    dataset,
    batch_size=8,
    shuffle=True,
)