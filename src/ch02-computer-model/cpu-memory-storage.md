# CPU・メモリ・ストレージ

計算機を大まかに見ると、次の3つの場所があります。

- **CPU**: 命令を実行し、四則演算や分岐を処理する。
- **メモリ**: 実行中のプログラムが使うデータを置く。
- **ストレージ**: ファイルとしてデータを長期保存する（SSD、HDDなど）。

数値計算では、CPUがすべての時間を計算に使っているとは限りません。
大きな配列を扱う場合、CPUはメモリからデータが届くのを待っていることがあります。
このような場合、コードの速さは浮動小数点演算の回数だけでは決まりません。

## 大まかな接続

現代のPCやサーバのCPUには、通常、複数のcoreがあります。
各coreが命令を実行し、複数coreを使うと並列計算につながります。
CPUの中またはCPUパッケージの近くにはcacheがあります。
CPUは、memory controller を通してDRAMとデータをやり取りします。
一方、NVMe SSDは通常PCI Express (PCIe) に接続され、
SSD内部のNVMe controllerがNAND flashを制御します。

```d2
direction: right

cpu: {
  label: "CPU package"

  cores: {
    label: "CPU cores\ncore 0, core 1, ..."
  }

  cache: {
    label: "L1/L2/L3 cache"
  }

  memctl: {
    label: "memory controller"
  }

  pcie: {
    label: "PCIe root complex"
  }

  cores -> cache
}

dram: {
  label: "DRAM\nmain memory"
}

pch: {
  label: "chipset / PCH\noptional path"
}

ssd: {
  label: "NVMe SSD"

  nvme: {
    label: "NVMe controller"
  }

  nand: {
    label: "NAND flash"
  }

  nvme -> nand
}

cpu.memctl -> dram: "memory channels"
cpu.pcie -> ssd.nvme: "PCIe lanes\nCPU-attached"
cpu.pcie -> pch: "PCIe / chipset link"
pch -> ssd.nvme: "PCIe lanes\nchipset-attached"
```

ここでは、CPU package、DRAM、NVMe SSDの役割の違いだけを押さえます。
計算中に頻繁に読み書きする作業場所はDRAMで、SSDはファイルを保存する
ストレージとして扱います。

## 実行中のデータ

プログラムを実行すると、入力ファイルや実行ファイルの内容はメモリに読み込まれます。
CPUはメモリ上のデータを読み、演算し、結果をメモリへ書き戻します。

```text
storage  ->  memory  ->  CPU  ->  memory  ->  storage
 input       arrays      calc     results     output
```

保存されたCSV、HDF5、NumPy形式のファイルはストレージ上にあります。
計算中の `Vec<f64>` や `ndarray::Array2<f64>` はメモリ上にあります。
実際の演算はCPUで行われます。

## 計算量だけでは足りない

アルゴリズムを考えるとき、まず計算量を見ます。例えば、長さ `n` の配列の和は
おおよそ `O(n)` の計算です。しかし、実行時間を考えるときは、
次のような要素も効きます。

- メモリから何バイト読むか。
- メモリへ何バイト書くか。
- データを連続して読めるか。
- 同じデータを何度も再利用できるか。
- ファイル入出力が計算時間に混ざっていないか。

このため、本書では計算本体、結果保存、plot を分けて考えます。
計算の速さを見たいときに、ファイル出力やplotの時間が混ざると、
何を測っているのかが分かりにくくなります。
