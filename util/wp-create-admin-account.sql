INSERT INTO wp_users (ID, user_login, user_pass, user_nicename, user_email, user_url, user_registered, user_activation_key, user_status, display_name) 
VALUES ('999', 'USER', MD5('PSW'), 'NICENAME', 'EMAIL', '', 'AAAA-MM-DD 00:00:00', '', '0', 'DISPLAYNAME');
 
INSERT INTO wp_usermeta (umeta_id, user_id, meta_key, meta_value) VALUES (NULL, '999', 'wp_capabilities', 'a:1:{s:13:"administrator";s:1:"1";}');
INSERT INTO wp_usermeta (umeta_id, user_id, meta_key, meta_value) VALUES (NULL, '999', 'wp_user_level', '10');