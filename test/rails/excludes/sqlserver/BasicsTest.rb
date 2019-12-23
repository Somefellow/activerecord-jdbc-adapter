# exclude some basic tests
exclude :test_an_explain_query_does_not_raise_if_preventing_writes, 'Explain in SQL Server will produce two extra queries (e.g. SET SHOWPLAN_TEXT ON/OFF)'

exclude :test_respect_internal_encoding, "missing transcoding?  Issue #883"

exclude :test_column_names_are_escaped, 'for sqlserver the bad char would be [ or ]'

exclude :test_find_keeps_multiple_group_values, 'sqlserver is more strict what it goes in the select and the GROUP BY'
