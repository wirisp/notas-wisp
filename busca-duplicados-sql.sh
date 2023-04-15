SELECT username, COUNT(*)  from radusergroup GROUP BY username HAVING COUNT(*)>1;
