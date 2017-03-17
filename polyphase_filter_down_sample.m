%% 降采样的多相滤波结构
% 理论上fs>8e3，D=8时需要先进行fs/2/8=500的抗混叠滤波器才行，我们试试将滤波器使用多相滤波结构放在下采样之后执行。
% 问题：fc设置的频点导致fc-n*fs在滤波器带宽范围内时，多相滤波很容易导致滤波不干净
% --原因大概是下采样后信号的频谱已经搬到该点了，这时候再滤波显然无法过滤掉这些在频点上的噪声，
% --而多相相加的时候并没有去除掉，怎么解决这个问题？

clear all; clc, close all;
%% 参数初始化
fs=8e3;%原始信号采样率
fc=[1e2,6.5e2,7e2];%信号频点，必须混叠内和外各有一个信号
p=[0,0,pi/2];%信号初始相位
a=[1,1,0.6];%信号幅度
D=8;%8倍抽取器
deAddF=[200,300];%抗混叠滤波器通带阻带
% deAddF=[fs/2/D/1.5,fs/2/D];%抗混叠滤波器通带阻带
phaseLen=512;%各相长度
signalLen=D*phaseLen;

%% 信号产生
[t,s]=cosSignalGen(fc,p,a,fs,signalLen);%plot(t,s,'.-') %采样1s产生叠加信号
x=awgn(s,100,'measured');%叠加噪声

%% 原型滤波器设计--Parks–McClellan算法
[n0,f0,m0,w]=remezord(deAddF,[1,0],[0.001,0.001],fs);%原型滤波器阶数计算%原型滤波器阶数 - [通带f,阻带f],[通带A,阻带A],[通带波纹,阻带波纹],fs
n0=ceil(n0/D)*D*2;%取I的整数倍，控制长度为2的整数倍，这样滤波延迟比较好计算
b=remez(n0,f0,m0,w);%计算原型滤波器系数

%% 信号频谱和滤波器响应
figure(1),subplot(311),title('信号频谱和滤波器响应');
[sf,sp]=myPsdCal(s,fs,length(s)); %计算叠加信号的功率谱
[bf,bp]=myPsdCal(b,fs,length(b));%计算滤波器幅频响应
plot(sf,sp,'bo-',bf,bp,'r.-'), legend('信号频谱','滤波器幅频响应');
xlabel('f/Hz');ylabel('A/dB');axis tight;
% 对原型滤波器进行多相分解
h=reshape(b(1:(end-1)),D,[]);%h(k,r)=b((r-1)*I+k);
% h=circshift(h,[1,0]);%根据框图需要上移一位【实际不移位也对？】

%% 直接抽取信号
yd=x(1:D:end);

%% 多相结构滤波---没有采样率变换就没有多相结构！！因此源采样率时用不着多相结构！
xp=reshape(x,D,[]);%多相结构的输入？？
for k=1:D
%     delay=round((size(h,2)-1)/2);%滤波延迟---各个滤波器自己的延时都是其长度的一半
    delay=size(h,2)/2-1;%滤波延迟---各个滤波器自己的延时都是其长度的一半
    ytmp=conv(xp(k,:),h(k,:));%频域滤波
    ytmp=circshift(ytmp,[0,-delay]);%去除延时
    y1(k,:)=ytmp(1:phaseLen);%取信号时长
end
y=sum(y1,1);%求和
ty=(0:1:phaseLen-1)/fs*D;%采样时长
%% 时域波形绘制
point=64;
figure(1),subplot(312),title('原始信号和下采样信号时域图');
plot(t(1:D*point),x(1:D*point),'k.-',ty(1:point),y(1:point),'ro-',ty(1:point),yd(1:point),'b+-'), 
legend('原始信号','多相下采样信号','直接抽取信号');
xlabel('t/s');ylabel('A/v');axis tight;
%% 频谱波形绘制
figure(1),subplot(313),title('原始信号和下采样信号频谱');
[xf,xp]=myPsdCal(x,fs,length(y)); %计算原始信号的功率谱
[yf,yp]=myPsdCal(y,fs/D,length(y));%计算多相滤波后信号的功率谱
[ydf,ydp]=myPsdCal(yd,fs/D,length(yd));%计算多相滤波后信号的功率谱
plot(xf,xp,'kp-',yf,yp,'ro-',ydf,ydp,'b+-'), 
legend('原始信号','多相下采样信号','直接抽取信号');
xlabel('f/Hz');ylabel('A/dB');axis tight;