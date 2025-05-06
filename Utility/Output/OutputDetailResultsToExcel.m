function OutputDetailResultsToExcel(AlgorithmName, AlgorithmParams, BenchmarkName, BenchmarkParams, Results, outputPath)
        % 1. 生成参数字符串（每参数占一行）
        paramData = {
            'Algorithm:', AlgorithmName;
            'Algorithm Parameters:', getParamString(AlgorithmParams);
            'Benchmark:', BenchmarkName;
            'Benchmark Parameters:', getParamString(BenchmarkParams);
        };
        
        % 2. 提取Results中需要导出的字段（排除基础字段）
        ResultsFields = getResultField(Results);
        totalColumns = 1 + numel(ResultsFields);
        paramDataAdjusted = [paramData, repmat({''}, 4, totalColumns - 2)];

        % 3. 构建数据表格主体
        if ~isempty(ResultsFields)
            runNumber = numel(Results.(ResultsFields{1}).AllResults);  % 获取总运行次数
        else
            runNumber = 0;
            warning('No valid result fields found.');
        end
        
        % 表头
        headers = [{'Run #'}, ResultsFields];  % 第一列标题 + 各字段名
        
        % 数据行（每行对应一轮运行）
        data = cell(runNumber, totalColumns); % +1 用于Run #列
        
        for i = 1:runNumber
            % 第一列：运行编号
            data{i, 1} = ['Run #', num2str(i)];
            
            % 后续列：各字段数据
            for j = 1:length(ResultsFields)
                field = ResultsFields{j};
                try
                    data{i, j+1} = Results.(field).AllResults(i);
                catch
                    data{i, j+1} = '';
                end
            end
        end

        data{end+1, 1} = 'Mean';
        for j = 1:length(ResultsFields)
            field = ResultsFields{j};
            try
                data{end, j+1} = Results.(field).mean;
            catch
                data{end, j+1} = '';
            end
        end

        data{end+1, 1} = 'Median';
        for j = 1:length(ResultsFields)
            field = ResultsFields{j};
            try
            data{end, j+1} = Results.(field).median;
            catch
                data{end, j+1} = '';
            end
        end

        data{end+1, 1} = 'Stardard Error';
        for j = 1:length(ResultsFields)
            field = ResultsFields{j};
            try
            data{end, j+1} = Results.(field).StdErr;
            catch
                data{end, j+1} = '';
            end
        end
        
        % 4. 组合所有内容（参数在前，空行分隔，表头+数据）
        fullOutput = [
            paramDataAdjusted;
            repmat({''}, 2, totalColumns); % 空行
            headers;
            data
        ];
        
        % 5. 创建输出目录（如果不存在）
        if ~exist(outputPath, 'dir')
            mkdir(outputPath);
        end
        
        % 6. 生成唯一文件名（带时间戳）
        filename = fullfile(outputPath, ...
            sprintf('%s_%s_%s.xlsx', AlgorithmName, BenchmarkName, datestr(now, 'yyyymmddTHHMMSS')));
        
        % 7. 写入Excel
        try
            writecell(fullOutput, filename, 'Sheet', 'Result');
        catch e
            error('导出失败: %s', e.message);
        end

   function paramStr = getParamString(paramStruct, prefix)
       if nargin < 2
           prefix = '';
       end
       paramList = {};
       fields = fieldnames(paramStruct);
       for k = 1:length(fields)
           fieldName = fields{k};
           fullFieldName = [prefix fieldName];
           fieldValue = paramStruct.(fieldName).value;
           
           if isnumeric(fieldValue)
               if isscalar(fieldValue)
                valueStr = sprintf('%.5f', fieldValue);
                valueStr = regexprep(valueStr, '(\.\d*?[1-9])0+$', '$1');
                valueStr = regexprep(valueStr, '\.0+$', '');
                else
                    if all(fieldValue >= 32 & fieldValue <= 126)
                        valueStr = ['"' char(fieldValue) '"'];
                    else
                        values = arrayfun(@(x) sprintf('%.5f', x), fieldValue, 'Uni', 0);
                        values = cellfun(@(s) regexprep(s, '(\.\d*?[1-9])0+$', '$1'), values, 'Uni', 0);
                        valueStr = ['[' strjoin(values, ' ') ']'];
                    end
                end
           elseif islogical(fieldValue)
               valueStr = mat2str(fieldValue);
           elseif ischar(fieldValue) || isstring(fieldValue)
               valueStr = char(fieldValue);
           elseif isstruct(fieldValue)
               subFields = fieldnames(fieldValue);
               if isscalar(subFields) && strcmp(subFields{1}, 'value')
                   if ischar(fieldValue.value) || isstring(fieldValue.value)
                       valueStr = ['"', char(fieldValue.value), '"'];
                   else
                       valueStr = sprintf('%.5f', fieldValue.value);
                       valueStr = regexprep(valueStr, '(\.\d*?[1-9])0+$', '$1');
                       valueStr = regexprep(valueStr, '\.0+$', '');
                   end
               else
                   valueStr = getParamString(fieldValue, [fullFieldName '.']);
               end
           elseif iscell(fieldValue)
               cellStrs = cellfun(@(x) getParamString(x, ''), fieldValue, 'UniformOutput', false);
               valueStr = ['{' strjoin(cellStrs, ',') '}'];
           else
               valueStr = '[Unknown Type]';
           end
           
           paramList{end+1} = sprintf('%s=%s', fullFieldName, valueStr);
       end
       paramStr = strjoin(paramList, ', ');
   end
   function ResultsFields = getResultField(Results)
       baseFields = {'Problem', 'CurrentError', 'VisualizationInfo', 'Iteration'};
       ResultsFields = {};
       resultFields = fieldnames(Results);
       currentFields = setdiff(resultFields, baseFields, 'stable');
       for idx = 1:numel(currentFields)
           field_i = currentFields{idx};
           if ~ismember(field_i, ResultsFields)
               ResultsFields{end+1} = field_i;
           end
       end
   end
end

