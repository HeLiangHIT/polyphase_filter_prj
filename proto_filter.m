%% 原始的滤波结构

clear all; clc, close all;
%% 参数初始化
fs=4e3;
fc=[1e2,6.5e2,7e2];%信号频点，必须混叠内和外各有一个信号
p=[0,0,pi/2];%信号初始相位
a=[1,1,1];%信号幅度
D=8;%8倍抽取器
phaseLen=8*512;%各相长度
signalLen=D*phaseLen;

%% 信号产生
[t,s]=cosSignalGen(fc,p,a,fs,signalLen);%plot(t,s,'.-') %采样1s产生叠加信号
x=awgn(s,50,'measured');%叠加噪声

%% 原型滤波器设计--Parks–McClellan算法
[n0,f0,m0,w]=remezord([150,200],[1,0],[0.001,0.001],fs);%原型滤波器阶数计算%原型滤波器阶数 - [通带f,阻带f],[通带A,阻带A],[通带波纹,阻带波纹],fs
n0=ceil(n0/D)*D*2;%取D的整数倍，控制长度为2的整数倍，这样滤波延迟比较好计算
b=remez(n0,f0,m0,w);%计算原型滤波器系数

%% 信号频谱和滤波器响应
figure(1),subplot(211),title('信号频谱和滤波器响应');
[sf,sp]=myPsdCal(s,fs,length(s)); %计算叠加信号的功率谱
[bf,bp]=myPsdCal(b,fs,length(b));%计算叠加信号的功率谱
plot(sf,sp,'bo-',bf,bp,'r.-'), legend('信号频谱','滤波器幅频响应');
xlabel('f/Hz');ylabel('A/dB');axis tight;
% 对原型滤波器进行多相分解
h=reshape(b(1:(end-1)),D,[]);%h(k,r)=b((r-1)*I+k);

%% 对信号进行直接频域滤波
N=length(x);
delay=round(length(b)/2)-1;%滤波延迟
% y1=ifft(fft(x,N).*fft(b,N));%频域滤波
y1=conv(x,b);%频域滤波
y1=circshift(y1,[0,-delay]);
y1=y1(1:length(t));
Point=128;
figure(1),subplot(212),title('滤波器前后的信号');
plot(t(1:Point),x(1:Point),'bo-',t(1:Point),y1(1:Point),'r.-');legend('滤波前','直接滤波后');
xlabel('t/s');ylabel('A/v');axis tight;


%% 多相结构滤波---没有采样率变换就没有多相结构！！因此源采样率时用不着多相结构！
% for k=1:D
%     xphase(k,:)=circshift(x,[0,k-1]);%x时延
%     yphase(k,:)=circshift(b,[0,k-1]);%x时延
%     %     x_tmp=ifft(fft(xphase(k,:),signalLen).*fft(h(k,:),signalLen));%滤波
%     x_tmp=conv(xphase(k,:),yphase(k,:));%频域滤波
%     x_tmp=circshift(x_tmp,[0,-delay]);
%     x_tmp=x_tmp(:,1:signalLen);
%     y2(k,:)=x_tmp;
%     %         figure(2),plot(t,x,'b.-',t,xphase(k,:),'ro-'),pause
% end
% y2=y2(:);
% y2=y2(1:D:end);%下采样
% figure(1),subplot(212),title('滤波器前后的信号');
% plot(t,x,'bo-',t,y1,'r.-',t,y2,'kx-');legend('滤波前','直接滤波后','多相滤波后');hold on;

