from simple_ffn_model import SequenceDetector
import torch
import snntorch as snn
from snntorch import utils
from torch import nn
from load_lr_rl_dataset import dataset

dtype = torch.float
device = torch.device("cuda") if torch.cuda.is_available() else torch.device("mps") if torch.backends.mps.is_available() else torch.device("cpu")

net = SequenceDetector()
net = net.to(device)

loss = nn.CrossEntropyLoss()
optimizer = torch.optim.Adam(net.parameters(), lr=5e-4)

generator = torch.Generator().manual_seed(42)
test_set, train_set = torch.utils.data.random_split(dataset, [int(0.8 * len(dataset)), int(0.2 * len(dataset))], generator=generator)


train_loss_list = []
for epoch in range(90):
    for data, label in train_set:
        total_loss = torch.tensor([0], device=device, dtype=dtype)
        for timestep_data in data:
            data = data.to(device)
            out, mem = net(data)
            mem = mem[0]
            mem = mem.to(device)
            one_hot_target = torch.zeros(2)
            one_hot_target[label] = 1
            one_hot_target = one_hot_target.to(device)
            #print(f"{mem}, {one_hot_target}")
            total_loss += loss(mem, one_hot_target)

        utils.reset(net)
        print(f"loss: {total_loss}")
        train_loss_list.append(total_loss[0])
        optimizer.zero_grad()
        total_loss.backward()
        optimizer.step()

test_loss_list = []
for data, label in test_set:
    total_loss = torch.tensor([0], device=device, dtype=dtype)
    for timestep_data in data:
        data = data.to(device)
        out, mem = net(data)
        mem = mem[0]
        mem = mem.to(device)
        one_hot_target = torch.zeros(2)
        one_hot_target[label] = 1
        one_hot_target = one_hot_target.to(device)
        total_loss += loss(mem, one_hot_target)
    print(f"test loss: {total_loss}")
    test_loss_list.append(total_loss[0])

print(f"train loss: {sum(train_loss_list)/len(train_loss_list)} test loss: {sum(test_loss_list)/len(test_loss_list)}")

    

        