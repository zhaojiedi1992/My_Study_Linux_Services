内存cpu简介
======================================

QPI ，又名CSI，Common System Interface公共系统接口，是一种可以实现芯片间直接互联的架构。

DMA 传输将数据从一个地址空间复制到另外一个地址空间。当CPU 初始化这个传输动作，
传输动作本身是由 DMA 控制器来实行和完成。典型的例子就是移动一个外部内存的区块到芯片内部更快的内存区。
像是这样的操作并没有让处理器工作拖延，反而可以被重新排程去处理其他的工作。DMA 传输对于高效能 嵌入式系统算法
和网络是很重要的。

isolcpus： 设置可使用的cpu。


优先级 1-140 

nice值 -20到120
