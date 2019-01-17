% ctcClass Testing

classes=categorical(cellstr(['a';'b']));
mat = [[0.4, 0, 0.6]; [0.4, 0, 0.6]]; 

newClasslayer = ctcClassificationLayer('ctcClass',classes);
expected = 0.64; 
actual = newClasslayer.ctcLabelingProb(mat, 'a'); 
distr(strcat('Expected: ', num2str(expected), 'Actual: ', num2str(actual));


