function queryId = queryNameToQueryId(queryName)
    queryId = strsplit(queryName, '.');
    queryId = queryId{1};
    queryId = str2num(queryId);
end