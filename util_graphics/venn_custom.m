function venn_custom(A, B, AB, titleText,Aname,Bname)
%VENN_CUSTOM  Simple 2-set Venn diagram
%   A  = count in set 1
%   B  = count in set 2
%   AB = overlap count
%   titleText = figure title
% Aname, Bname: names to use for A and B

%figure('Color','w'); 
hold on; axis equal off;

% Circle centers
r  = 1; 
d  = 0.8;   % overlap distance
theta = linspace(0,2*pi,200);
x1 = r*cos(theta); y1 = r*sin(theta);
x2 = d + r*cos(theta); y2 = r*sin(theta);

fill(x1,y1,[0.6 0.8 1],'FaceAlpha',0.6,'EdgeColor','none'); % blue
fill(x2,y2,[1 0.6 0.6],'FaceAlpha',0.6,'EdgeColor','none'); % red

% Text labels
text(-0.7,0.6,sprintf('%s only = %d',Aname,A),'Color','b','FontSize',12);
text(1.3,0.6,sprintf('%s only = %d',Bname,B),'Color','r','FontSize',12);
text(0.3,0,sprintf('Overlap = %d',AB),'Color','k','FontSize',12,...
     'FontWeight','bold');

title(titleText,'FontWeight','bold');
end
