IO_RDR = xlsread('C:\Users\KNUST\Desktop\Results_IDA\fragility curves\IO_fractal_matrix_RDR.xlsx');
LS_RDR = xlsread('C:\Users\KNUST\Desktop\Results_IDA\fragility curves\LS_fractal_matrix_RDR.xlsx');
CP_RDR = xlsread('C:\Users\KNUST\Desktop\Results_IDA\fragility curves\CP_fractal_matrix_RDR.xlsx');

IO_MIDR = xlsread('C:\Users\KNUST\Desktop\Results_IDA\fragility curves\IO_fractal_matrix_MIDR.xlsx');
LS_MIDR = xlsread('C:\Users\KNUST\Desktop\Results_IDA\fragility curves\LS_fractal_matrix_MIDR.xlsx');
CP_MIDR = xlsread('C:\Users\KNUST\Desktop\Results_IDA\fragility curves\CP_fractal_matrix_MIDR.xlsx');

rel_RDR(:,:,1) = (repmat(IO_RDR(3,:),3,1)-IO_RDR)./repmat(IO_RDR(3,:),3,1)*100;
rel_RDR(:,:,2) = (repmat(LS_RDR(3,:),3,1)-LS_RDR)./repmat(LS_RDR(3,:),3,1)*100;
rel_RDR(:,:,3) = (repmat(CP_RDR(3,:),3,1)-CP_RDR)./repmat(CP_RDR(3,:),3,1)*100;

rel_MIDR(:,:,1) = (repmat(IO_MIDR(3,:),3,1)-IO_MIDR)./repmat(IO_MIDR(3,:),3,1)*100;
rel_MIDR(:,:,2) = (repmat(LS_MIDR(3,:),3,1)-LS_MIDR)./repmat(LS_MIDR(3,:),3,1)*100;
rel_MIDR(:,:,3) = (repmat(CP_MIDR(3,:),3,1)-CP_MIDR)./repmat(CP_MIDR(3,:),3,1)*100;

x_coords = [10,20,30];
ticks = 10:10:30; 
fig_names = {'IO Relative Collapse Reduction for RDR','LS Relative Collapse Reduction for RDR','CP Relative Collapse Reduction for RDR';...
    'IO Relative Collapse Reduction for MIDR','LS Relative Collapse Reduction for MIDR','CP Relative Collapse Reduction for MIDR'};

% plot relative curves of RDR
for i=1:3
    figure ( 'Name' , fig_names{1,i} , 'NumberTitle' , 'off' );
    hold on
    
    plot(x_coords,rel_RDR(:,1,i), '-b', 'linewidth', 1)
    plot(x_coords,rel_RDR(:,2,i), '--r', 'linewidth', 1)
    plot(x_coords,rel_RDR(:,3,i), '-.k', 'linewidth', 1)
    
    plot(x_coords,rel_RDR(:,1,i), 'ob', 'linewidth', 1)
    plot(x_coords,rel_RDR(:,2,i), 'or', 'linewidth', 1)
    plot(x_coords,rel_RDR(:,3,i), 'ok', 'linewidth', 1)
    
    legh = legend('14th percentile', '50th percentile', '86th percentile');
    set(legh, 'fontsize', 12, 'Location', 'southwest')
    xlabel('Compressive Strength (N/mm^{2})', 'Fontsize', 14);
    ylabel('Relative Reduction in Collapse Capacity (%)', 'Fontsize', 14);
    
    xlim([5,35]);
    set(gca, 'XTickMode', 'manual', 'XTick', ticks)
    set(gca, 'Ydir' , 'reverse' )
    set(gca, 'Xdir' , 'reverse' )
    set(gca, 'Box', 'on')
    
end
hold off


% plot relative curves of MIDR
for i=1:3
    figure ( 'Name' , fig_names{2,i} , 'NumberTitle' , 'off' );
    hold on
    
    plot(x_coords,rel_MIDR(:,1,i), '-b', 'linewidth', 1)
    plot(x_coords,rel_MIDR(:,2,i), '--r', 'linewidth', 1)
    plot(x_coords,rel_MIDR(:,3,i), '-.k', 'linewidth', 1)
    
    plot(x_coords,rel_MIDR(:,1,i), 'ob', 'linewidth', 1)
    plot(x_coords,rel_MIDR(:,2,i), 'or', 'linewidth', 1)
    plot(x_coords,rel_MIDR(:,3,i), 'ok', 'linewidth', 1)
    
    legh = legend('14th percentile', '50th percentile', '84th percentile');
    set(legh, 'fontsize', 12, 'Location', 'southwest')
    xlabel('Compressive Strength (N/mm^{2})', 'Fontsize', 14);
    ylabel('Relative Reduction in Collapse Capacity (%)', 'Fontsize', 14);
    
    xlim([5,35]);
    set(gca, 'XTickMode', 'manual', 'XTick', ticks)
    set(gca, 'Ydir' , 'reverse' )
    set(gca, 'Xdir' , 'reverse' )
    set(gca, 'Box', 'on')
end 

hold off


xlswrite('C:\Users\KNUST\Desktop\Results_IDA\relative reduction curves\relative_fractal_matrix_RDR.xlsx',rel_RDR(:,:,1),'IO');
xlswrite('C:\Users\KNUST\Desktop\Results_IDA\relative reduction curves\relative_fractal_matrix_RDR.xlsx',rel_RDR(:,:,2),'LS');
xlswrite('C:\Users\KNUST\Desktop\Results_IDA\relative reduction curves\relative_fractal_matrix_RDR.xlsx',rel_RDR(:,:,3),'CP');


xlswrite('C:\Users\KNUST\Desktop\Results_IDA\relative reduction curves\relative_fractal_matrix_MIDR.xlsx',rel_MIDR(:,:,1),'IO');
xlswrite('C:\Users\KNUST\Desktop\Results_IDA\relative reduction curves\relative_fractal_matrix_MIDR.xlsx',rel_MIDR(:,:,2),'LS');
xlswrite('C:\Users\KNUST\Desktop\Results_IDA\relative reduction curves\relative_fractal_matrix_MIDR.xlsx',rel_MIDR(:,:,3),'CP');
