%% Output to Excel
function OutputExcel(AlgorithmName,BenchmarkName,ChangeFrequency,Dimension,PeakNumber,ShiftSeverity,RunNumber,EnvironmentNumber,E_o,E_bbc,pathout)
    disp('Outputing to Excel: please wait for a while...');
    Result = cell(1,3);
    Result{1,1} = 'Algorithm';
    Result{end+1,1} = AlgorithmName;
    Result{end+1,1} = ' ';
    Result{end,2} = ' ';
    Result{end,3} = ' ';
    
    Result{end+1,1} = 'Problem Instance Information';
    Result{end+1,1} = 'Benchmark Name';
    Result{end,2} = BenchmarkName;
    Result{end+1,1} = 'Change Frequency';
    Result{end,2} = ChangeFrequency;
    Result{end+1,1} = 'Dimension';
    Result{end,2} = Dimension;
    Result{end+1,1} = 'Number of Promising Regions';
    Result{end,2} = PeakNumber;
    Result{end+1,1} = 'Shift Severity';
    Result{end,2} = ShiftSeverity;
    Result{end+1,1} = 'Environment Number';
    Result{end,2} = EnvironmentNumber;
    
    Result{end+1,1} = ' ';
    Result{end,2} = ' ';
    Result{end,3} = ' ';
    Result{end+1,1} = 'Results and Statistics';
    Result{end+1,1} = '';
    Result{end,2} = 'Offline Error';
    Result{end,3} = 'Average Error Before Change';
    for i = 1:RunNumber
        Result{end+1,1} = ['Run #',num2str(i)];
        Result{end,2} = E_o.AllResults(i);
        Result{end,3} = E_bbc.AllResults(i);
    end
    Result{end+1,1} = 'Average';
    Result{end,2} = E_o.mean;
    Result{end,3} = E_bbc.mean;
    Result{end+1,1} = 'Median';
    Result{end,2} = E_o.median;
    Result{end,3} = E_bbc.median;
    Result{end+1,1} = 'Standard Error';
    Result{end,2} = E_o.StdErr;
    Result{end,3} = E_bbc.StdErr;
    pathout = [pathout,'\',AlgorithmName,'_',BenchmarkName,'_',char(datestr(now,30)),'.xlsx'];
    xlswrite(pathout,Result,1,'A1');
    % Change excel sttle
    hExcel = actxserver('excel.application');
    set(hExcel, 'Visible', 1);
    hWorkbooks = hExcel.Workbooks.Open(char(System.IO.Path.GetFullPath(pathout)));
    hSheets=hExcel.ActiveWorkBook.Sheets.Item(1);
    hSheets.Range('A1:C1').ColumnWidth=32;  % Width
    hSheets.Range('A1:AF58').RowHeight=30;    % Height
    hSheets.Range('A1:AF58').HorizontalAlignment=3; % Alignment horizontal center
    hSheets.Range('A1:AF58').VerticalAlignment=2;   % Alignment vertical center
    hSheets.Range('A1:AF58').Font.name = 'Times New Roman'; % Font style is Times New Roman
    
    hSheets.Range('A1:A1').Font.bold = 2;  % Font blod
    hSheets.Range('A1:A1').Font.size = 18; % Font size
    hSheets.Range('A1:A1').Font.color = 255; % Font color
    hSheets.Range('A1:A1').Font.underline  = 2; % Underline
    hSheets.Range('A1:C1').MergeCells = 1;
    hSheets.Range('A2:C2').MergeCells = 1;
    hSheets.Range('A4:A4').Font.bold = 2;  % Font blod
    hSheets.Range('A4:A4').Font.size = 18; % Font size
    hSheets.Range('A4:A4').Font.color = 255; % Font color
    hSheets.Range('A4:A4').Font.underline  = 2; % Underline
    hSheets.Range('A4:C4').MergeCells = 1;

    hSheets.Range('A12:A12').Font.bold = 2;  % Font blod
    hSheets.Range('A12:A12').Font.size = 18; % Font size
    hSheets.Range('A12:A12').Font.color = 255; % Font color
    hSheets.Range('A12:A12').Font.underline  = 2; % Underline
    hSheets.Range('A12:C12').MergeCells = 1; % Merge cells

    hSheets.Range('A1:A1').Font.bold = 2;  % Font blod
    hSheets.Range('A1:A1').Font.size = 18; % Font size
    hSheets.Range('A1:A1').Font.color = 255; % Font color
    hSheets.Range('A1:A1').Font.underline  = 2; % Underline
    hSheets.Range('A1:C1').MergeCells = 1;
    hSheets.Range('A2:A2').Font.bold = 2;  % Font blod
    hSheets.Range('A5:A10').Font.bold = 2;  % Font blod
    hSheets.Range('A5:A10').Font.size = 12; % Font size
    hSheets.Range('A5:A10').Font.color = 11829830; % Font color
    for i = [2,5,6,7,8,9,10]
        hSheets.Range(['B',num2str(i),':','C',num2str(i)]).MergeCells = 1;
    end
    
    hSheets.Range('A13:C13').Font.bold = 2;  % Font blod
    hSheets.Range('A13:C13').Font.size = 14; % Font size
    hSheets.Range('A13:C13').Font.color = 16711680; % Font color
    
    hSheets.Range(['A14',':A',num2str(14 + RunNumber - 1)]).Font.color = 6316128; % Font color
    hSheets.Range(['A14',':A',num2str(14 + RunNumber - 1)]).Font.Italic = 2; % Italic
    
    hSheets.Range(['A',num2str(14 + RunNumber),':A',num2str(14 + RunNumber + 3)]).Font.bold = 2;  % Font blod
    hSheets.Range(['A',num2str(14 + RunNumber),':A',num2str(14 + RunNumber + 3)]).Font.underline  = 2;
    hSheets.Range(['A',num2str(14 + RunNumber),':A',num2str(14 + RunNumber + 3)]).Font.color = 6711039; % Font color
    hSheets.Range('B1:C1').Font.bold = 2;  % Font blod
    hSheets.Range('B1:C1').Font.size = 14; % Font size
    
    hWorkbooks.Save;
    hWorkbooks.Saved=true;

end

