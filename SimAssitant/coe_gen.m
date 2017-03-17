%% 正弦波信号的产生，用户*.mif文件的填充
clear,clc,close all;
bitWidth=8;%位宽
addrWidth=10;%地址位宽
romLen=2^addrWidth;%ROM长度
t=(0:romLen-1)/romLen*2*pi;%时间
data=floor(2^(bitWidth-1)*sin(t));
data=2^(bitWidth-1)+data;

h=fopen('sinwave.coe','w');
fprintf(h,'MEMORY_INITIALIZATION_RADIX=10;\r\n');%采用10进制表示的数据
fprintf(h,'MEMORY_INITIALIZATION_VECTOR=\r\n');%采用10进制表示的数据
for k=1:length(data)-1
    if data(k)>2^bitWidth-1
        data(k)=2^bitWidth-1;
    end
    fprintf(h,'%d,\r\n',data(k));
end
fprintf(h,'%d;\r\n',data(end));
fclose(h);

%% DDS频率计算公式
fclk=50e6;%时钟频率
fprintf('最大输出频率为%e，最小输出频率为[精度]%e\n',fclk/2,fclk/romLen);
% 根据fword计算输出频率
fword=1;%频率控制字
pword=0;%相位控制字
fout=fword*fclk/romLen;%频率计算
pout=pword*2*pi/romLen;%相位计算
fprintf('fword=%d,pword=%d时 ，输出频率f=%e， 输出周期T=%e ，输出相位p=%e \n',...
                fword,pword,fout,1/fout,pout);

%绘制波形图
% data_out=data(1:fword:end);
% t_out=t(1:fword:end);
% stairs(t_out,data_out,'r');axis tight;

% 根据f_target计算fword，输出的最高频率是fclk/2
ftarget=4e5;%目标频率
ptarget=0;%目标相位
fword=round(romLen*ftarget/fclk);%频率->频率控制字
pword=round(romLen*ptarget/2/pi);%相位->相位控制字
fprintf('fword=%d,pword=%d时，输出频率为f=%e， 输出周期T=%e，相位为p=%f\n',...
                fword,   pword,  fword*fclk/romLen,  romLen/fword/fclk,     pword*2*pi/romLen);
%绘制波形图
% data_out=data(1:fword:end);
% t_out=t(1:fword:end);
% stairs(t_out,data_out,'r');axis tight;
