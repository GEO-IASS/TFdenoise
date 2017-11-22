function label=down_subcube_kmeans(DataCube,subcube_size,overlap_pixel,k,maxItr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%�²�������
if (nargin<5)
    maxItr=100;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\n\n���࿪ʼ\n');
tStart=tic;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[m,n,p]=size(DataCube);
mm=ceil((m-subcube_size(1))/overlap_pixel)+1;
nn=ceil((n-subcube_size(2))/overlap_pixel)+1;
pp=ceil((p-subcube_size(3))/overlap_pixel)+1;

DownMm=floor((m-subcube_size(1))/subcube_size(1));
DownNn=floor((n-subcube_size(2))/subcube_size(2));
DownPp=floor((p-subcube_size(3))/subcube_size(3));


if(k>mm*nn*pp)
   error('subcube_kmeans:tooManyClusters','���������ࡣ'); 
end
%%��ʼ�����ĵ�
centers=zeros([subcube_size(1)*subcube_size(2)*subcube_size(3),k]);

initial_idx=randsample(mm*nn*pp,k);
[xx,yy,zz]=ind2sub([mm,nn,pp],initial_idx);

for i=1:k
    [x_rg,y_rg,z_rg]=get_subcube_index(DataCube,subcube_size,overlap_pixel,xx(i),yy(i),zz(i));
    temp=DataCube(x_rg,y_rg,z_rg);
    centers(:,i)=temp(:);
end
fprintf('��ʼ������');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
label1=ones(DownMm,DownNn,DownPp);

itrCount=0;
last=0;
while( any(label1~=last) )
    last=label1;    
    for ii=1:DownMm
        for jj=1:DownNn
            for kk=1:DownPp
                itemp=(ii-1)*subcube_size(1)+1;
                jtemp=(jj-1)*subcube_size(2)+1;
                ktemp=(kk-1)*subcube_size(3)+1;
                [x_rg,y_rg,z_rg]=get_subcube_index(DataCube,subcube_size,overlap_pixel,itemp,jtemp,ktemp);
                temp=DataCube(x_rg,y_rg,z_rg);
                %%�õ�������С��K�±�
                 label1(ii,jj,kk)=min(dist(temp(:)',centers),[],2);
%                 label1(ii,jj,kk)=ceil(rand()*k);
                
            end
        end
    end
    fprintf('һ�ξ������');
    %��ֵ
    for i=1:k
        [xx,yy,zz]=ind2sub([DownMm,DownNn,DownPp],find(label1(:)==i));
        %%��ĳһ��Ϊ���࣬�������һ������
        if(isempty(xx))
            random_idx=randsample(mm*nn*pp,1);
            [xx,yy,zz]=ind2sub([mm,nn,pp],random_idx);
            [x_rg,y_rg,z_rg]=get_subcube_index(DataCube,subcube_size,overlap_pixel,xx,yy,zz);
            temp=DataCube(x_rg,y_rg,z_rg);
            centers(:,i)=temp(:);
        else
            sum_cube=zeros(subcube_size(1)*subcube_size(2)*subcube_size(3),1);
            for ii=1:length(xx)
                [x_rg,y_rg,z_rg]=get_subcube_index(DataCube,subcube_size,overlap_pixel,xx(ii),yy(ii),zz(ii));
                temp=DataCube(x_rg,y_rg,z_rg);
                sum_cube=sum_cube+temp(:);
            end
            centers(:,i)=sum_cube/length(xx);
        end    
    end
    itrCount=itrCount+1;
    fprintf('k-means��%d�ε���\n',itrCount);
    toc(tStart);
    if (itrCount>=maxItr)
        warning('stats:subcube_kmeans:FailedToConverge','%d�ε�����δ�ﵽ������',maxItr);
        break;
    end
end
fprintf('���ĵ�����');
toc(tStart);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%��δ�����Ŀ����
label2=ones(mm,nn,pp);
for ii=1:mm
        for jj=1:nn
            for kk=1:pp
                [x_rg,y_rg,z_rg]=get_subcube_index(DataCube,subcube_size,overlap_pixel,ii,jj,kk);
                temp=DataCube(x_rg,y_rg,z_rg);
                label2(ii,jj,kk)=min(dist(temp(:)',centers),[],2);
            end
        end
end

label=label2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\n�������\n');
toc(tStart);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function D=dist(X,Y)
% D = sqrt(bsxfun(@plus,dot(X,X,2),dot(Y,Y,1))-2*(X*Y));
D = bsxfun(@plus,dot(X,X,2),dot(Y,Y,1))-2*(X*Y); %ŷ�Ͼ���ƽ��

