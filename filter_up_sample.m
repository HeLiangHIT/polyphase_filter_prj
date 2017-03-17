%% 升采样的原始滤波结构
% 理论上fs=2e3，I=8时需要后进行fs/2的抗混叠滤波器才行，我们试试将滤波器使用多相滤波结构放在下采样之后执行。

clear all; clc, close all;
%% 参数初始化
fs=2e3;%原始采样率
fc=[1e2,6.5e2,7e2];%信号频点，必须混叠内和外各有一个信号
p=[0,0,pi/2];%信号初始相位
a=[1,1,0.8];%信号幅度
I=8;%8倍内插器
deAddF=[fs/2,fs/2+100];%抗混叠滤波器通带阻带
phaseLen=512;%各相长度
signalLen=I*phaseLen;

%% 信号产生
[t,s]=cosSignalGen(fc,p,a,fs,phaseLen);%plot(t,s,'.-') %采样1s产生叠加信号
x=awgn(s,5,'measured');%叠加噪声

%% 原型滤波器设计--Parks–McClellan算法
[n0,f0,m0,w]=remezord(deAddF,[1,0],[0.001,0.001],fs*I);%原型滤波器阶数计算%原型滤波器阶数 - [通带f,阻带f],[通带A,阻带A],[通带波纹,阻带波纹],fs
n0=ceil(n0/I)*I*2;%取I的整数倍，控制长度为2的整数倍，这样滤波延迟比较好计算
b=remez(n0,f0,m0,w);%计算原型滤波器系数

%% 信号频谱和滤波器响应
figure(1),subplot(311),title('信号频谱和滤波器响应');
[sf,sp]=myPsdCal(s,fs,length(s)); %计算叠加信号的功率谱
[bf,bp]=myPsdCal(b,fs*I,length(b));%计算滤波器幅频响应
plot(sf,sp,'bo-',bf,bp,'r.-'), legend('原始信号频谱','滤波器幅频响应');
xlabel('f/Hz');ylabel('A/dB');axis tight;

%% 直接插值信号
yu=zeros(1,signalLen);
yu(1:I:end)=x;
tu=(0:signalLen-1)/fs/I;
% yu=repmat(x,I,1);%使用复制前一个的方法实现upSampling
% yu=yu(:)';
% yu = yu/I;

%% 对信号进行直接频域滤波
N=length(x);
delay=round(length(b)/2)-1;%滤波延迟
% y1=ifft(fft(x,N).*fft(b,N));%频域滤波
y=I*conv(yu,b,'same');%频域滤波
% y=circshift(y,[0,-delay]);
% y=y(1:length(t));

%% 绘图
Point=64;
figure(1),subplot(312),title('原始升采样各阶段的信号');
plot(t(1:Point),x(1:Point),'k.-',tu(1:Point*I),yu(1:Point*I),'b+',tu(1:Point*I),y(1:Point*I),'ro-');legend('原始信号','直接插值后','滤波后');
xlabel('t/s');ylabel('A/v');axis tight;

figure(1),subplot(313),title('原始信号和升采样信号频谱');
[xf,xp]=myPsdCal(x,fs,length(x)); %计算原始信号的功率谱
[yuf,yup]=myPsdCal(yu,fs*I,length(yu));%计算直接滤波后信号的功率谱
[yf,yp]=myPsdCal(y,fs*I,length(y));%计算多相滤波后信号的功率谱
plot(xf,xp,'kp-',yuf,yup,'b+-',yf,yp,'ro-'), 
legend('原始信号功率谱','插值后的的功率谱','滤波后的功率谱');
xlabel('f/Hz');ylabel('A/dB');axis tight;
