% --- OPTION A (robust): Dominant electrode counts by gesture ---

T = resultsTable;   % <-- change if your table variable name differs

% 1) Group rows by (gestureName, bestCh)
[Gid, gestureGroup, chGroup] = findgroups(T.gestureName, T.bestCh);

% 2) Count how many rows in each group
counts = splitapply(@numel, T.bestCh, Gid);

% 3) Build a clean counts table
countTable = table(gestureGroup, chGroup, counts, ...
    'VariableNames', {'gestureName','bestCh','count'});

% 4) Convert counts table into matrix for stacked bar plot
gestures   = unique(countTable.gestureName, 'stable');
electrodes = unique(countTable.bestCh);

% make sure electrodes are sorted if numeric
electrodes = sort(electrodes);

M = zeros(numel(gestures), numel(electrodes));
for i = 1:height(countTable)
    r = find(gestures == countTable.gestureName(i));
    c = find(electrodes == countTable.bestCh(i));
    M(r,c) = countTable.count(i);
end

% 5) Plot
figure
bar(M, 'stacked')
xticks(1:numel(gestures))
xticklabels(gestures)
ax = gca;
ax.XAxis.FontSize = 8;
xlabel("Gesture")
ylabel("Number of trials where channel was best")
title("Dominant (Best) Electrode by Gesture Across Trials")
legend("Ch " + string(electrodes), 'Location', 'eastoutside')
grid on

% 6) Save outputs
if ~exist("figures","dir"); mkdir("figures"); end
if ~exist("results","dir"); mkdir("results"); end

exportgraphics(gcf, "figures/plotA_dominantElectrode_counts.png", "Resolution", 300);
writetable(countTable, "results/plotA_bestCh_counts.csv");
