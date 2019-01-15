%% Process files
global extComments
clear all
clc

voxforge_dir = 'F:\DataSets\Voxforge\';
ads  = audioDatastore(voxforge_dir,'IncludeSubfolders' , 1);
TotalFiles = numel(ads.Files);

VocData = categorical(cellstr(['à';'á';'â';'ã';'ä';'å';'¸';'æ';'ç';'è';'é';'ê';'ë';'ì';'í';'î';'ï';'ð';'ñ';'ò';'ó';'ô';'õ';'ö';'÷';'ø';'ù';'ú';'û';'ü';'ý';'þ';'ÿ';'-']));
VocNum = [1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;18;19;20;21;22;23;24;25;26;27;28;29;30;31;32;33;34];
VocDictionary = table(VocData,VocNum,'VariableNames',{'VocData';'VocNum'});

%% 
if numel(who('extComments'))==0 extComments=true; end;
processAll = 1; % 1 - all files from scratch; 2 - only from errorsIdx
p = gcp();

if (processAll==1)
    
    clear features featLenArray targets tagLenArray
    tagLenArray=[]; % Targets lenths
    featLenArray=[]; % Features lenths

    parfor i=1:TotalFiles
           FName=string(ads.Files(i));                  
           if (extComments) disp(strcat('Processing with: ', num2str(i), ' file:', FName)); end;
           strokaText=extract_targets(FName,VocDictionary);
           targets{i} = strokaText';
           tagLenArray(i)=numel(strokaText);
           [audioFile, SRate]  = audioread(FName); 
           [pitch1, mfcc1,featLen] = extract_features(audioFile,SRate);
           features{i}= mfcc1';
           featLenArray(i)=featLen;
    end
    
    saveName='ProcessedDataNew.mat';
    
elseif (processAll==2)% process only files with errors
    
   load 'ProcessedData.mat';
    parfor i=1:numel(errorsIdx)
           FName=string(ads.Files(errorsIdx(i)));
           if (extComments) disp(strcat('Processing with: ', num2str(i), ' file:', FName)); end;
           strokaText=extract_targets(FName,VocDictionary);
           targets{:,errorsIdx(i)} = strokaText;
           tagLenArray(errorsIdx(i))=numel(strokaText);
    end
    
    saveName='ProcessedDataAdd.mat';
    
   elseif (processAll==3) % process only files by tall arrays
    
       tDs=tall(ads);
       targets = cellfun(@(x)extract_targets(x,VocDictionary), T,"UniformOutput",false);
       features = cellfun(@(x)extract_features(x,VocDictionary), T,"UniformOutput",false);
       [targets,predictors] = gather(targets,predictors);       
       
       saveName='ProcessedDataTall.mat';
end


 
 %% check for errors
 errorsIdx = find(tagLenArray==0); 
 errNums= numel(errorsIdx);
  if errNums>0 
      disp(strcat(num2str(errNums),' files are processed with errors!'));
      for i=1:errNums
          disp(strcat('---',string(ads.Files(errorsIdx(i)))));
      end
  end;
  
 save(saveName,'features','targets','featLenArray','tagLenArray','VocDictionary', 'errorsIdx');
 clear p voxforge_dir VocNum VocData ads TotalFiles 
% system('shutdown /s /f /t 60')