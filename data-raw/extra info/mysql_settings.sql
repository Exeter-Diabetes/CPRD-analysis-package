set role 'role_full_admin';

show variables like 'key_buffer_size';
SET GLOBAL key_buffer_size=214748364800;
show variables like 'key_buffer_size';

show variables like 'sort_buffer_size';
SET sort_buffer_size=214748364799;
show variables like 'sort_buffer_size';

show variables like 'myisam_sort_buffer_size';
SET myisam_sort_buffer_size=214748364799;
show variables like 'myisam_sort_buffer_size';

show variables like 'read_buffer_size';
SET read_buffer_size=2147479552;
show variables like 'read_buffer_size';

show variables like 'read_rnd_buffer_size';
SET read_rnd_buffer_size=2147483647;
show variables like 'read_rnd_buffer_size';

show variables like 'join_buffer_size';
SET join_buffer_size=214748364672;
show variables like 'join_buffer_size';

show variables like 'preload_buffer_size';
SET preload_buffer_size=1073741824;
show variables like 'preload_buffer_size';

show variables like 'max_heap_table_size';
SET max_heap_table_size=214748363776;
show variables like 'max_heap_table_size';

show variables like 'tmp_table_size';
SET tmp_table_size=214748364799;
show variables like 'tmp_table_size';

show variables like 'max_join_size';
SET max_join_size=18446744073709500000;
show variables like 'max_join_size';

show variables like 'myisam_max_sort_file_size';
SET myisam_max_sort_file_size=9223372036853720000;
show variables like 'myisam_max_sort_file_size';

show variables like 'innodb_buffer_pool_size';
SET GLOBAL innodb_buffer_pool_size=2147483648;
show variables like 'innodb_buffer_pool_size';
