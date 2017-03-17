%% 升采样的多相滤波结构
% 理论上fs=4e3，I=8时需要后进行fs/2的抗混叠滤波器才行，我们试试将滤波器使用多相滤波结构放在下采样之后执行。

clear all; clc, close all;
%% 参数初始化
fs=2e3;%原始采样率
fc=[1e2,5e2];%信号频点，必须混叠内和外各有一个信号
p=[0,0];%信号初始相位
a=[1,1];%信号幅度
I=8;%8倍内插器
deAddF=[fs/2/2,fs/2];%抗混叠滤波器通带阻带
phaseLen=512;%各相长度
signalLen=I*phaseLen;

%% 信号产生
[t,s]=cosSignalGen(fc,p,a,fs,phaseLen);%plot(t,s,'.-') %采样1s产生叠加信号
x=awgn(s,100,'measured');%叠加噪声

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
% 对原型滤波器进行多相分解
h=reshape(b(1:(end-1)),I,[]);%h(k,r)=b((r-1)*I+k);
% h=circshift(h,[1,0]);%这样会导致错误

%% 直接插值信号
yu=zeros(1,signalLen);
yu(1:I:end)=x;

%% 多相结构滤波---没有采样率变换就没有多相结构！！因此源采样率时用不着多相结构！
xp=repmat(x,I,1);%多相结构的输入
for k=1:I
    delay=size(h,2)/2;%滤波延迟---各个滤波器自己的延时都是其长度的一半
%     delay=round((size(h,2)-1)/2);%滤波延迟---各个滤波器自己的延时都是其长度的一半
    ytmp=I*conv(xp(k,:),h(k,:));%频域滤波
    ytmp=circshift(ytmp,[0,-delay]);%去除延时
    y1(k,:)=ytmp(1:phaseLen);%取信号时长
end
y=y1(:);%移相相加
ty=(0:1:signalLen-1)/fs/I;%采样时长
%% 时域波形绘制
point=64;
figure(1),subplot(312),title('原始信号和升采样信号时域图');
plot(t(1:point),x(1:point),'k.-',ty(1:I*point),y(1:I*point),'ro-',ty(1:I*point),yu(1:I*point),'b+-'), 
legend('原始信号','多相升采样信号','直接插值信号');
xlabel('t/s');ylabel('A/v');axis tight;
%% 频谱波形绘制
figure(1),subplot(313),title('原始信号和升采样信号频谱');
[xf,xp]=myPsdCal(x,fs,length(x)); %计算原始信号的功率谱
[yf,yp]=myPsdCal(y,fs*I,length(x));%计算多相滤波后信号的功率谱
[yuf,yup]=myPsdCal(yu,fs*I,length(x));%计算多相滤波后信号的功率谱
plot(xf,xp,'kp-',yf,yp,'ro-',yuf,yup,'b+-'), 
legend('原始信号','多相升采样信号','直接插值信号');
xlabel('f/Hz');ylabel('A/dB');axis tight;