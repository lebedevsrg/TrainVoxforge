function  stroka = decode_digital(strDigit, VocDictionary)
global extComments 

    nStr = numnel(strDigit);
    stroka = '';
    for i=1:nStr
        VocDictionary
        iNum =  VocDictionary.VocNum==strDigit(j);
        stroka = strcat(ret,string(VocDictionary{iNum,1}));
    end

    if (extComments) disp(strcat('Decoded Text: ', stroka)); end;
end