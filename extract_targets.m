%% extract_targets

function  stroka = extract_targets(fileName,VocDictionary)
global extComments 

foundTrue = 0;
dicTemp = table;

% extract targets         
        fileSplit = strsplit(fileName,'\');
        fileNameLast= fileSplit(end);
        fileSplit(end-1)='etc';
        fileSplit(end)='prompts-original';
        fileLetters = strjoin(fileSplit,'\');        
        disp(strcat('Processing file: ', fileName,'. Sentences container:',fileLetters));
        stroka = [];
        
        [fileID,errmsg] = fopen(fileLetters,'r','n' ,'UTF-8');
        if (length(errmsg)>0) 
            disp(['Error opening file: ' errmsg]); 
        else    % Ok to open
            while ~feof(fileID)
                tline = fgetl(fileID);
                tlineSplit = strsplit(tline,' '); 
                checkFile = contains(fileNameLast,string(tlineSplit (1)));
                if (checkFile==1) 
                    foundTrue= 1;
                    original= strjoin(tlineSplit(2:end));
                    original = erase(original, ['.', "'",'-',',',]);
                    original = lower(strip(replace(original,'  ', ' ')));
                    targets = strsplit(original,' ');                
                    for i=1:numel(targets)
                        lensStr = char(cellstr(targets(i)));
                        tlen = length(lensStr); % num of symbols in sentence
                        for j = 1: tlen                     
                            try
                                iNum =  VocDictionary.VocData==lensStr(j);
                            catch ME
                                disp(ME.message)
                                disp(strcat('Try to convert:  ',  lensStr(j), ' failed! IndexNum; File name:', fileName))
                                iNum=0;
                            end
                            vocalNum = VocDictionary{iNum,2};
                            stroka = vertcat(stroka,vocalNum);
                        end % end For j
                        if (i<numel(targets)) stroka = vertcat(stroka,34); end;
                    end % end For i
                end   % end IF         
            end % end While    
             fclose(fileID);   
        end;  % end IF                 

       if (foundTrue==0) 
           disp(strcat('Original Text is Not found:', fileName));
       else    
          andf=num2str(stroka');
          if (extComments) disp(strcat('Original Text: [', original, ']; converted to: ', andf)); end;
        end
end