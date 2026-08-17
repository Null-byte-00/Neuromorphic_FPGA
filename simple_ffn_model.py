import torch
from torch import nn
import snntorch as snn
from snntorch import surrogate


class SequenceDetector(nn.Module):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.spike_grad = surrogate.fast_sigmoid()
        """
        self.net = nn.Sequential(
            nn.Linear(5,4),
            snn.Leaky(beta=0.9, init_hidden=True, spike_grad=self.spike_grad),
            nn.Linear(4, 1),
            snn.Leaky(beta=0.9, init_hidden=True, spike_grad=self.spike_grad)
        )
        """
        self.l1 = nn.Linear(5,6)
        self.lif1 = snn.Leaky(beta=0.9, spike_grad=self.spike_grad)
        self.l2 = nn.Linear(6,2)
        self.lif2 = snn.Leaky(beta=0.9, spike_grad=self.spike_grad)


    def forward(self, x):
        l1_out = self.l1(x)
        lif1_out, mem1 = self.lif1(l1_out)
        l2_out = self.l2(lif1_out)
        lif2_out, mem2 = self.lif2(l2_out)
        return lif2_out, mem2
