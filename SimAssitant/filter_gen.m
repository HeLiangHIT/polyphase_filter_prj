%% 原始的滤波结构

clear all; clc, close all;
%% 参数初始化
fs=50e6;
fc=[2e5,10e5];%信号频点，必须混叠内和外各有一个信号
deAddF=[2.5e5,9e5];%抗混叠滤波器通带阻带
p=[0,0];%信号初始相位
a=[1,1];%信号幅度
signalLen=1024;

%% 信号产生
[t,s]=cosSignalGen(fc,p,a,fs,signalLen);%plot(t,s,'.-') %采样1s产生叠加信号
x=awgn(s,50,'measured');%叠加噪声

%% 原型滤波器设计--Parks–McClellan算法
[n0,f0,m0,w]=remezord(deAddF,[1,0],[0.001,0.001],fs);%原型滤波器阶数计算%原型滤波器阶数 - [通带f,阻带f],[通带A,阻带A],[通带波纹,阻带波纹],fs
n0=64;
b=remez(n0,f0,m0,w);%计算原型滤波器系数

%% 信号频谱和滤波器响应
figure(1),subplot(211),title('信号频谱和滤波器响应');
[sf,sp]=myPsdCal(s,fs,length(s)); %计算叠加信号的功率谱
[bf,bp]=myPsdCal(b,fs,length(b));%计算叠加信号的功率谱
plot(sf,sp,'bo-',bf,bp,'r.-'), legend('信号频谱','滤波器幅频响应');
xlabel('f/Hz');ylabel('A/dB');axis tight;

%% 对信号进行直接频域滤波
N=length(x);
delay=round(length(b)/2)-1;%滤波延迟
y1=conv(x,b);%频域滤波
y1=circshift(y1,[0,-delay]);
y1=y1(1:length(t));
Point=signalLen;
figure(1),subplot(212),title('滤波器前后的信号');
plot(t(1:Point),x(1:Point),'bo-',t(1:Point),y1(1:Point),'r.-');legend('滤波前','直接滤波后');
xlabel('t/s');ylabel('A/v');axis tight;


% 系数整理和保存
h=fopen('hn.txt','w');
scale=2^8/max(b);%根据hn的位数决定缩放
for k=1:length(b)
    fprintf(h,'%d\r\n',round(scale*b(k)));
end
fclose(h);
