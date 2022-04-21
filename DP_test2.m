clc
clear all;

[load, strings, raw]=xlsread('Dp_test2','Sheet1');
[load2, strings, raw]=xlsread('DP_test2','Sheet2');


%% Data insertion

Pmin=load(:,2);
Pmax=load(:,3);
Min_up=load(:,4);
Min_down=load(:,5);
Noload_cost=load(:,6);
Marginal_cost=load(:,7);
Startup_cost=load(:,8)
Initial_status=load(:,9);

costmat=[load(:,6) load(:,7) load(:,8)];
powermat=[load(:,2) load(:,3) (load(:,3)-load(:,2))];
hr_load=load2(:,1); %% hourly load

%%Formulation of 1st feasible states
%n=size(Pmin)
n=input("input number of generator units(for current example, keep it 3)"); %% No of units
Truth_Table =( truth_table(n));   %generate(n)

T=Truth_Table
T(:,4)=zeros
size=2^(n);
  for k=1:size
    T(k,4)=generatesum(k,n,T,Pmin);   %% n=3
    T(k,5)=generatesum(k,n,T,Pmax);   %% n=3
  end
T=sortrows(T,4,'descend') %% All states truth table

Feasible=[];
hour=input("Input no of hours. (For current example, you could keep it to 3)");  %% no of hours load is run
for i=1:hour
    k=1;
    for j=1:size
    if(hr_load(i)>=T(j,4) && hr_load(i)<=T(j,5))
        Feasible(k,i)=1;
    else
        Feasible(k,i)=0;
       
    end
    k=k+1;
    end
end
serialno=[1:size]';
Feasible= [serialno,T,Feasible] % FEASIBLE STATES MATRIX

uptime=Min_up;
downtime=Min_down;
%% Find out the initial state number
y=0;
for i=1:size
if((Initial_status'==Feasible(i,2:4)))
    y=i;
    break;
end
end

start=y; 
%% uptime downtime matrix
for i=1:n
    UpTime(i)=uptime(i);
    DownTime(i)=downtime(i);
end
sno=[1:n];
UpDownmat=[sno',UpTime',DownTime'];
UpDownmatorig=UpDownmat;


load=hr_load;
prev_state=start;
strt=Feasible(start,2:4);
for i=1:n
    if(strt(i)==1)
        UpDownmat(i,2)=-100;
    else
        UpDownmat(i,3)=-100;
    end
end
UpDownmat

F=[];
arr=[];
feas=0;
%% Loop for the next states
%temp=100000;
for i=1:hour
    %nextstate=[];
     prev_state=start;
        start=prev_state;
    temp=inf;temp3=1;
   for j=1:size
       k=1;
       
    if(i==1)
        %prev_state=start;
        pprev_state=start;
        if(Feasible(j,6+i)==1)
            
           
            %nextstate=([nextstate Feasible(j,1)]) %% 1st hour next state
            
            %cur_state(i,k)=Feasible(j,1);
            cur_state=Feasible(j,1);
           
           [cost]=optcost(Feasible(cur_state,2:4),Feasible(prev_state,2:4),costmat,powermat,load(i),n);
           
           [flag]=possiblestate(Feasible(cur_state,2:4),Feasible(prev_state,2:4),UpDownmat,UpDownmatorig,n)
           

           
           
              %cost=optcost([1 0 1],[1 0 0],costmat,powermat,300)
            if(cost<=temp && flag==1)
                temp=cost;
                feas_state=cur_state;
                %prev_cost=cost;
                temp3=cur_state;
              
                prev_state=cur_state;
                
                feas_state=temp3
             end
            
        end 
        
        %arr(1,i)=temp3;
        
        %arr(2,i)=prev_cost;
        
       %h=prev_state
    else
       % if(i~=2)
       %prev_state=feas_state;
        %end
        if(Feasible(j,6+i)==1)
            
             cur_state=Feasible(j,1);
             
          
           
           [cost]=optcost(Feasible(cur_state,2:4),Feasible(prev_state,2:4),costmat,powermat,load(i),n);
           [flag]=possiblestate(Feasible(cur_state,2:4),Feasible(prev_state,2:4),UpDownmat,UpDownmatorig,n);
        

           %cost=optcost([1 1 1],[1 0 0],costmat,powermat,300)
           Tc=prev_cost+cost;
           temp2=cur_state;
          
           if(Tc<=temp && flag==1)
                temp=Tc;
                temp3=Feasible(j,1);
                feas_state=cur_state;
                start=feas_state;
                %prev_cost=Tc;
               
            end
        
          end
    end
    
   end
  %x=start
  z=prev_state;
   [UpDownmat]=update(Feasible(start,2:4),Feasible(prev_state,2:4),UpDownmat,UpDownmatorig,n)
  % prev_state=cur_state;
   arr(1,i)=feas_state;
   prev_cost=temp;
   
   %temp4=temp3;
   %arr(1,i)=(temp3);
  
   arr(2,i)=prev_cost;
   
   %state=temp3;
   
       
end
a=Feasible(arr(1,:),2:4);
display('  state                         Genstates                   Totalcost');
a=[arr(1,:)' a arr(2,:)']
%dj=size(arr)
%prev_cost=costupdated;
 
%% FUNCTION TO GENERATE SUM

function [val]=generatesum(k,i,T,p)

    sum=0;
 for j=1:i
    sum=sum+T(k,j)*p(j);
 end
val=sum;
T(k,j+1)=val;

end

%% Truth table function
function T=truth_table(N)
L = 2^N;
T = zeros(L,N);
for i=1:N
   temp = [zeros(L/2^i,1); ones(L/2^i,1)];
   T(:,i) = repmat(temp,2^(i-1),1);
end
end


