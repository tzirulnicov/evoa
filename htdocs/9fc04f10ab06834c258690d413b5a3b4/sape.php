<?php
/*
 *
 * Нет необходимости что-либо менять в этом файле. Все настройки можно задать при вызове кода.
 * Подробнее — в документации.
 *
 */
define('LINKFEED_USER',  '3b790774acdad3a09657911888bac34d1d0b3958');
define('LINKFEED_FIRST', false);

class Linkfeed_emulation {
    var $lc_version           = '0.3.8';
    var $lc_verbose           = false;
    var $lc_charset           = 'DEFAULT';
    var $lc_use_ssl           = false;
    var $lc_server            = 'db.linkfeed.ru';
    var $lc_cache_lifetime    = 3600;
    var $lc_cache_reloadtime  = 300;
    var $lc_links_db_file     = '';
    var $lc_links             = array();
    var $lc_links_page        = array();
    var $lc_links_delimiter   = '';
    var $lc_error             = '';
    var $lc_host              = '';
    var $lc_request_uri       = '';
    var $lc_fetch_remote_type = '';
    var $lc_socket_timeout    = 6;
    var $lc_force_show_code   = false;
    var $lc_multi_site        = false;
    var $lc_is_sape_bot       = false;
    var $lc_is_static         = false;

    function Linkfeed_emulation($options = null) {
        $host = '';

        if (is_array($options)) {
            if (isset($options['host'])) {
                $host = $options['host'];
            }
        } elseif (strlen($options) != 0) {
            $host = $options;
            $options = array();
        } else {
            $options = array();
        }

        if (strlen($host) != 0) {
            $this->lc_host = $host;
        } else {
            $this->lc_host = $_SERVER['HTTP_HOST'];
        }

        $this->lc_host = preg_replace('{^https?://}i', '', $this->lc_host);
        $this->lc_host = preg_replace('{^www\.}i', '', $this->lc_host);
        $this->lc_host = strtolower( $this->lc_host);

        if (isset($options['is_static']) && $options['is_static']) {
            $this->lc_is_static = true;
        }

        if (isset($options['request_uri']) && strlen($options['request_uri']) != 0) {
            $this->lc_request_uri = $options['request_uri'];
        } else {
            if ($this->lc_is_static) {
                $this->lc_request_uri = preg_replace( '{\?.*$}', '', $_SERVER['REQUEST_URI']);
                $this->lc_request_uri = preg_replace( '{/+}', '/', $this->lc_request_uri);
            } else {
                $this->lc_request_uri = $_SERVER['REQUEST_URI'];
            }
        }

        if ((isset($options['verbose']) && $options['verbose']) ||
            isset($this->lc_links['__linkfeed_debug__'])) {
            $this->lc_verbose = true;
        }

        if (isset($options['charset']) && strlen($options['charset']) != 0) {
            $this->lc_charset = $options['charset'];
        }

        if (isset($options['multi_site']) && $options['multi_site'] == true) {
            $this->lc_multi_site = true;
        }

        if (isset($options['fetch_remote_type']) && strlen($options['fetch_remote_type']) != 0) {
            $this->lc_fetch_remote_type = $options['fetch_remote_type'];
        }

        if (isset($options['socket_timeout']) && is_numeric($options['socket_timeout']) && $options['socket_timeout'] > 0) {
            $this->lc_socket_timeout = $options['socket_timeout'];
        }

        if ((isset($options['force_show_code']) && $options['force_show_code']) ||
            isset($this->lc_links['__linkfeed_debug__'])) {
            $this->lc_force_show_code = true;
        }
        
        if (!defined('LINKFEED_USER')) {
            return $this->raise_error("Constant LINKFEED_USER is not defined.");
        }

        $this->load_links();
    }

    function load_links() {
        if ($this->lc_multi_site) {
            $this->lc_links_db_file = dirname(__FILE__) . '/../' . LINKFEED_USER . '/linkfeed.' . $this->lc_host . '.links.db';
        } else {
            $this->lc_links_db_file = dirname(__FILE__) . '/../' . LINKFEED_USER . '/linkfeed.links.db';
        }
        
        if (!is_file($this->lc_links_db_file)) {

            if (@touch($this->lc_links_db_file, time() - $this->lc_cache_lifetime)) {
                @chmod($this->lc_links_db_file, 0666);
            } else {
                return $this->raise_error("There is no file " . $this->lc_links_db_file . ". Fail to create. Set mode to 777 on the folder.");
            }
        }

        if (!is_writable($this->lc_links_db_file)) {
            return $this->raise_error("There is no permissions to write: " . $this->lc_links_db_file . "! Set mode to 777 on the folder.");
        }

        @clearstatcache();

        if (filemtime($this->lc_links_db_file) < (time()-$this->lc_cache_lifetime) || 
           (filemtime($this->lc_links_db_file) < (time()-$this->lc_cache_reloadtime) && filesize($this->lc_links_db_file) == 0)) {

            @touch($this->lc_links_db_file, time());

            $path = '/' . LINKFEED_USER . '/' . strtolower( $this->lc_host) . '/' . strtoupper( $this->lc_charset);

            if ($links = $this->fetch_remote_file($this->lc_server, $path)) {
                if (substr($links, 0, 12) == 'FATAL ERROR:') {
                    $this->raise_error($links);
                } else if (@unserialize($links) !== false) {
                    $this->lc_write($this->lc_links_db_file, $links);
                } else {
                    $this->raise_error("Cann't unserialize received data.");
                }
            }
        }

        $links = $this->lc_read($this->lc_links_db_file);
        $this->lc_file_change_date = gmstrftime ("%d.%m.%Y %H:%M:%S",filectime($this->lc_links_db_file));
        $this->lc_file_size = strlen( $links);
        if (!$links) {
            $this->lc_links = array();
            $this->raise_error("Empty file.");
        } else if (!$this->lc_links = @unserialize($links)) {
            $this->lc_links = array();
            $this->raise_error("Cann't unserialize data from file.");
        }

        if (isset($this->lc_links['__linkfeed_delimiter__'])) {
            $this->lc_links_delimiter = $this->lc_links['__linkfeed_delimiter__'];
        }

        if (array_key_exists($this->lc_request_uri, $this->lc_links) && is_array($this->lc_links[$this->lc_request_uri])) {
            $this->lc_links_page = $this->lc_links[$this->lc_request_uri];
        }
        $this->lc_links_count = count($this->lc_links_page);
    }

    function delimiter() {
        return $this->lc_links_delimiter;
    }

    function links_count() {
        return count($this->lc_links_page);
    }

    function is_sape_bot( $is_sape_bot) {
        $this->lc_is_sape_bot = $is_sape_bot;
    }

    function return_links($n = null) {
return 'links!!!';
        $result = '';
        if (isset($this->lc_links['__linkfeed_start__']) && strlen($this->lc_links['__linkfeed_start__']) != 0 &&
            (in_array($_SERVER['REMOTE_ADDR'], $this->lc_links['__linkfeed_robots__']) || $this->lc_force_show_code)
        ) {
            $result .= $this->lc_links['__linkfeed_start__'];
        }

        if (isset($this->lc_links['__linkfeed_robots__']) && in_array($_SERVER['REMOTE_ADDR'], $this->lc_links['__linkfeed_robots__']) || $this->lc_verbose) {

            if ($this->lc_error != '') {
                $result .= $this->lc_error;
            }

            $result .= '<!--REQUEST_URI=' . $_SERVER['REQUEST_URI'] . "-->\n"; 
            $result .= "\n<!--\n"; 
            $result .= 'LS ' . $this->lc_version . "\n"; 
            $result .= 'REMOTE_ADDR=' . $_SERVER['REMOTE_ADDR'] . "\n"; 
            $result .= 'request_uri=' . $this->lc_request_uri . "\n"; 
            $result .= 'charset=' . $this->lc_charset . "\n"; 
            $result .= 'is_static=' . $this->lc_is_static . "\n"; 
            $result .= 'multi_site=' . $this->lc_multi_site . "\n"; 
            $result .= 'file change date=' . $this->lc_file_change_date . "\n";
            $result .= 'lc_file_size=' . $this->lc_file_size . "\n";
            $result .= 'lc_links_count=' . $this->lc_links_count . "\n";
            $result .= 'left_links_count=' . count($this->lc_links_page) . "\n";
            $result .= 'n=' . $n . "\n"; 
            $result .= '-->'; 
        }

        if (is_array($this->lc_links_page)) {
            $total_page_links = count($this->lc_links_page);

            if (!is_numeric($n) || $n > $total_page_links) {
                $n = $total_page_links;
            }

            $links = array();

            for ($i = 0; $i < $n; $i++) {
                $links[] = array_shift($this->lc_links_page);
            }

            if ( count($links) > 0 && isset($this->lc_links['__linkfeed_before_text__']) ) {
               $result .= $this->lc_links['__linkfeed_before_text__'];
            }

            $result .= implode($this->lc_links_delimiter, $links);

            if ( count($links) > 0 && isset($this->lc_links['__linkfeed_after_text__']) ) {
               $result .= $this->lc_links['__linkfeed_after_text__'];
            }
        }
        if (isset($this->lc_links['__linkfeed_end__']) && strlen($this->lc_links['__linkfeed_end__']) != 0 &&
            (in_array($_SERVER['REMOTE_ADDR'], $this->lc_links['__linkfeed_robots__']) || $this->lc_force_show_code)
        ) {
            $result .= $this->lc_links['__linkfeed_end__'];
        }

        if ($this->lc_is_sape_bot) {
            $result = '<sape_noindex>' . $result . '</sape_noindex>';
        }

        return $result;
    }

    function fetch_remote_file($host, $path) {
        $user_agent = 'LinkfeedSape Client PHP ' . $this->lc_version;

        @ini_set('allow_url_fopen', 1);
        @ini_set('default_socket_timeout', $this->lc_socket_timeout);
        @ini_set('user_agent', $user_agent);

        if (
            $this->lc_fetch_remote_type == 'file_get_contents' || (
                $this->lc_fetch_remote_type == '' && function_exists('file_get_contents') && ini_get('allow_url_fopen') == 1
            )
        ) {
            if ($data = @file_get_contents('http://' . $host . $path)) {
                return $data;
            }
        } elseif (
            $this->lc_fetch_remote_type == 'curl' || (
                $this->lc_fetch_remote_type == '' && function_exists('curl_init')
            )
        ) {
            if ($ch = @curl_init()) {
                @curl_setopt($ch, CURLOPT_URL, 'http://' . $host . $path);
                @curl_setopt($ch, CURLOPT_HEADER, false);
                @curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
                @curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, $this->lc_socket_timeout);
                @curl_setopt($ch, CURLOPT_USERAGENT, $user_agent);

                if ($data = @curl_exec($ch)) {
                    return $data;
                }

                @curl_close($ch);
            }
        } else {
            $buff = '';
            $fp = @fsockopen($host, 80, $errno, $errstr, $this->lc_socket_timeout);
            if ($fp) {
                @fputs($fp, "GET {$path} HTTP/1.0\r\nHost: {$host}\r\n");
                @fputs($fp, "User-Agent: {$user_agent}\r\n\r\n");
                while (!@feof($fp)) {
                    $buff .= @fgets($fp, 128);
                }
                @fclose($fp);

                $page = explode("\r\n\r\n", $buff);

                return $page[1];
            }
        }

        return $this->raise_error("Cann't connect to server: " . $host . $path);
    }

    function lc_read($filename) {
        $fp = @fopen($filename, 'rb');
        @flock($fp, LOCK_SH);
        if ($fp) {
            clearstatcache();
            $length = @filesize($filename);
            $mqr = get_magic_quotes_runtime();
            set_magic_quotes_runtime(0);
            if ($length) {
                $data = @fread($fp, $length);
            } else {
                $data = '';
            }
            set_magic_quotes_runtime($mqr);
            @flock($fp, LOCK_UN);
            @fclose($fp);

            return $data;
        }

        return $this->raise_error("Cann't get data from the file: " . $filename);
    }

    function lc_write($filename, $data) {
        $fp = @fopen($filename, 'wb');
        if ($fp) {
            @flock($fp, LOCK_EX);
            $length = strlen($data);
            @fwrite($fp, $data, $length);
            @flock($fp, LOCK_UN);
            @fclose($fp);

            if (md5($this->lc_read($filename)) != md5($data)) {
                return $this->raise_error("Integrity was breaken while writing to file: " . $filename);
            }

            return true;
        }

        return $this->raise_error("Cann't write to file: " . $filename);
    }

    function raise_error($e) {
        $this->lc_error = '<!--ERROR: ' . $e . '-->';
        return false;
    }
}

/*
 *  Классы для работы с sape
 */

class SAPE_base {
    
    var $_version           = '1.0.3';
    
    var $_verbose           = false;
    
    var $_charset           = '';               // http://www.php.net/manual/en/function.iconv.php
    
    var $_server_list       = array('dispenser-01.sape.ru', 'dispenser-02.sape.ru');
    
    var $_cache_lifetime    = 3600;             // Пожалейте наш сервер :о)
    
    // Если скачать базу ссылок не удалось, то следующая попытка будет через столько секунд
    var $_cache_reloadtime  = 600;
    
    var $_error             = '';
    
    var $_host              = '';
    
    var $_request_uri       = '';
    
    var $_multi_site        = false;
    
    var $_fetch_remote_type = '';              // Способ подключения к удалённому серверу [file_get_contents|curl|socket]
    
    var $_socket_timeout    = 6;               // Сколько ждать ответа
    
    var $_force_show_code   = false;
    
    var $_is_our_bot 		= false;           //Если наш робот

    var $_debug             = false;
        
	var $_db_file     		= '';				//Путь к файлу с данными

    function SAPE_base($options = null) {

        // Поехали :o)
        
        $host = '';
        
        if (is_array($options)) {
            if (isset($options['host'])) {
                $host = $options['host'];
            }
        } elseif (strlen($options)) {
            $host = $options;
            $options = array();
        } else {
            $options = array();
        }
        
        // Какой сайт?
        if (strlen($host)) {
            $this->_host = $host;
        } else {
            $this->_host = $_SERVER['HTTP_HOST'];
        }
        
        $this->_host = preg_replace('/^http:\/\//', '', $this->_host);
        $this->_host = preg_replace('/^www\./', '', $this->_host);
        
        // Какая страница?
        if (isset($options['request_uri']) && strlen($options['request_uri'])) {
            $this->_request_uri = $options['request_uri'];
        } else {
            $this->_request_uri = $_SERVER['REQUEST_URI'];
        }
        
        // На случай, если хочется много сайтов в одной папке
        if (isset($options['multi_site']) && $options['multi_site'] == true) {
            $this->_multi_site = true;
        }
        
        // Сообщать об ошибках
        if (isset($options['verbose']) && $options['verbose'] == true) {
            $this->_verbose = true;
        }
        
        // Кодировка
        if (isset($options['charset']) && strlen($options['charset'])) {
            $this->_charset = $options['charset'];
        }
        
        if (isset($options['fetch_remote_type']) && strlen($options['fetch_remote_type'])) {
            $this->_fetch_remote_type = $options['fetch_remote_type'];
        }
        
        if (isset($options['socket_timeout']) && is_numeric($options['socket_timeout']) && $options['socket_timeout'] > 0) {
            $this->_socket_timeout = $options['socket_timeout'];
        }
        
        // Всегда выводить чек-код
        if (isset($options['force_show_code']) && $options['force_show_code'] == true) {
            $this->_force_show_code = true;
        }
        
        // Выводить информацию о дебаге
        if (isset($options['debug']) && $options['debug'] == true) {
            $this->_debug = true;
        }

        if (!defined('_SAPE_USER')) {
            return $this->raise_error('Не задана константа _SAPE_USER');
        }
        
        // Определяем наш ли робот
        if (isset($_COOKIE['sape_cookie']) && ($_COOKIE['sape_cookie'] == _SAPE_USER)) {
            $this->_is_our_bot = true;
            if (isset($_COOKIE['sape_debug']) && ($_COOKIE['sape_debug'] == 1)){
                $this->_debug = true;
    }
        } else {
            $this->_is_our_bot = false;
        }
        
        //Перемешиваем список
        srand((float)microtime() * 1000000);
      //  shuffle($this->_server_list);
            }
        
        
    /*
     * Функция для подключения к удалённому серверу
     */
    function fetch_remote_file($host, $path) {
        
        $user_agent = $this->_user_agent.' '.$this->_version;
        
        @ini_set('allow_url_fopen',          1);
        @ini_set('default_socket_timeout',   $this->_socket_timeout);
        @ini_set('user_agent',               $user_agent);
        if (
            $this->_fetch_remote_type == 'file_get_contents'
            ||
            (
                $this->_fetch_remote_type == ''
                &&
                function_exists('file_get_contents')
                &&
                ini_get('allow_url_fopen') == 1
            )
        ) {
			$this->_fetch_remote_type = 'file_get_contents';
            if ($data = @file_get_contents('http://' . $host . $path)) {
                return $data;
            }
        
        } elseif (
            $this->_fetch_remote_type == 'curl' 
            ||
            (
                $this->_fetch_remote_type == ''
                &&
                function_exists('curl_init')
            )
        ) {
			$this->_fetch_remote_type = 'curl';
            if ($ch = @curl_init()) {

                @curl_setopt($ch, CURLOPT_URL,              'http://' . $host . $path);
                @curl_setopt($ch, CURLOPT_HEADER,           false);
                @curl_setopt($ch, CURLOPT_RETURNTRANSFER,   true);
                @curl_setopt($ch, CURLOPT_CONNECTTIMEOUT,   $this->_socket_timeout);
                @curl_setopt($ch, CURLOPT_USERAGENT,        $user_agent);
                
                if ($data = @curl_exec($ch)) {
                    return $data;
                }
                
                @curl_close($ch);
            }
            
        } else {
			$this->_fetch_remote_type = 'socket';
            $buff = '';
            $fp = @fsockopen($host, 80, $errno, $errstr, $this->_socket_timeout);
            if ($fp) {
                @fputs($fp, "GET {$path} HTTP/1.0\r\nHost: {$host}\r\n");
                @fputs($fp, "User-Agent: {$user_agent}\r\n\r\n");
                while (!@feof($fp)) {
                    $buff .= @fgets($fp, 128);
                }
                @fclose($fp);
                
                $page = explode("\r\n\r\n", $buff);
            
                return $page[1];
            }
            
        }
        
        return $this->raise_error('Не могу подключиться к серверу: ' . $host . $path.', type: '.$this->_fetch_remote_type);
    }
    
    /*
     * Функция чтения из локального файла
     */
    function _read($filename) {
        
        $fp = @fopen($filename, 'rb');
        @flock($fp, LOCK_SH);
        if ($fp) {
            clearstatcache();
            $length = @filesize($filename);
            $mqr = get_magic_quotes_runtime();
            set_magic_quotes_runtime(0);
            if ($length) {
                $data = @fread($fp, $length);
            } else {
                $data = '';
            }
            set_magic_quotes_runtime($mqr);
            @flock($fp, LOCK_UN);
            @fclose($fp);
            
            return $data;
        }
        
        return $this->raise_error('Не могу считать данные из файла: ' . $filename);  
    }
    
    /*
     * Функция записи в локальный файл
     */
    function _write($filename, $data) {
        
        $fp = @fopen($filename, 'wb');
        if ($fp) {
            @flock($fp, LOCK_EX);
            $length = strlen($data);
            @fwrite($fp, $data, $length);
            @flock($fp, LOCK_UN);
            @fclose($fp);
            
            if (md5($this->_read($filename)) != md5($data)) {
                return $this->raise_error('Нарушена целостность данных при записи в файл: ' . $filename); 
            }
            
            return true;
        }
        
        return $this->raise_error('Не могу записать данные в файл: ' . $filename); 
    }
    
    /*
     * Функция обработки ошибок
     */
    function raise_error($e) {
        
        $this->_error = '<p style="color: red; font-weight: bold;">SAPE ERROR: ' . $e . '</p>';
        
        if ($this->_verbose == true) {
            print $this->_error;
        }
        
        return false;
    }

    function load_data() {
        $this->_db_file = $this->_get_db_file();

        if (!is_file($this->_db_file)) {
            // Пытаемся создать файл.
            if (@touch($this->_db_file)) {
                @chmod($this->_db_file, 0666);    // Права доступа
            } else {
                return $this->raise_error('Нет файла ' . $this->_db_file . '. Создать не удалось. Выставите права 777 на папку.');
}
        }

        if (!is_writable($this->_db_file)) {
            return $this->raise_error('Нет доступа на запись к файлу: ' . $this->_db_file . '! Выставите права 777 на папку.');
        }

        @clearstatcache();

        if (filemtime($this->_db_file) < (time()-$this->_cache_lifetime) || filesize($this->_db_file) == 0) {

            // Чтобы не повесить площадку клиента и чтобы не было одновременных запросов
            @touch($this->_db_file, (time() - $this->_cache_lifetime + $this->_cache_reloadtime));

            $path = $this->_get_dispenser_path();
            if (strlen($this->_charset)) {
                $path .= '&charset=' . $this->_charset;
            }

            foreach ($this->_server_list as $i => $server){
	            if ($data = $this->fetch_remote_file($server, $path)) {
	                if (substr($data, 0, 12) == 'FATAL ERROR:') {
	                    $this->raise_error($data);
	                } else {
	                    // [псевдо]проверка целостности:
	                    if (@unserialize($data) != false) {
	                        $this->_write($this->_db_file, $data);
	                        break;
	                    }
	                }
	            }
            }
        }

        // Убиваем PHPSESSID
        if (strlen(session_id())) {
            $session = session_name() . '=' . session_id();
            $this->_request_uri = str_replace(array('?'.$session,'&'.$session), '', $this->_request_uri);
        }

        if ($data = $this->_read($this->_db_file)) {
        	$this->set_data(@unserialize($data));
        }
    }
}

class SAPE_emulation extends SAPE_base {

	var $_links_delimiter = '';
	var $_links = array();
	var $_links_page = array();
	var $_user_agent = 'SAPE_Client PHP';

    function SAPE_emulation($options = null) {
    	parent::SAPE_base($options);
        $this->load_data();
    }

    /*
     * Ccылки можно показывать по частям
     */
    function return_links($n = null, $offset = 0) {

        if (is_array($this->_links_page)) {

            $total_page_links = count($this->_links_page);

            if (!is_numeric($n) || $n > $total_page_links) {
                $n = $total_page_links;
            }

            $links = array();

            for ($i = 1; $i <= $n; $i++) {
                if ($offset > 0 && $i <= $offset) {
                    array_shift($this->_links_page);
                } else {
                    $links[] = array_shift($this->_links_page);
                }
            }

            $html = join($this->_links_delimiter, $links);
            
            if ($this->_is_our_bot) {
                $html = '<sape_noindex>' . $html . '</sape_noindex>';
            }
            
            return $html;

        } else {
            return $this->_links_page;
        }

    }

    function _get_db_file() {
        if ($this->_multi_site) {
            return dirname(__FILE__) . '/' . $this->_host . '.links.db';
        } else {
            return dirname(__FILE__) . '/links.db';
        }
    }

    function _get_dispenser_path(){
    	return '/code.php?user=' . _SAPE_USER . '&host=' . $this->_host;
    }

    function set_data($data){
    	$this->_links = $data;
        if (isset($this->_links['__sape_delimiter__'])) {
            $this->_links_delimiter = $this->_links['__sape_delimiter__'];
        }
        if (array_key_exists($this->_request_uri, $this->_links) && is_array($this->_links[$this->_request_uri])) {
            $this->_links_page = $this->_links[$this->_request_uri];
        } else {
        	if (isset($this->_links['__sape_new_url__']) && strlen($this->_links['__sape_new_url__'])) {
        		if ($this->_is_our_bot || $this->_force_show_code){
        			$this->_links_page = $this->_links['__sape_new_url__'];
        		}
        	}
        }
    }

    function is_sape_bot() {
        return $this->_is_our_bot;
    }

    function delimiter() {
        return $this->_links_delimiter;
    }

    function links_count() {
        return count($this->_links_page);
    }

}


class SAPE_context extends SAPE_base {

	var $_words = array();
	var $_words_page = array();
	var $_user_agent = 'SAPE_Context PHP';
    var $_filter_tags = array( "a", "textarea", "select", "script", "style", "label", "noscript" , "noindex", "button" );

    function SAPE_context($options = null) {
		parent::SAPE_base($options);
        $this->load_data();
    }

    /*
     * Замена слов в куске текста и обрамляет его тегами sape_index
     *
     */

    function replace_in_text_segment($text){
        $debug = '';
        if ($this->_debug){
            $debug .= "<!-- argument for replace_in_text_segment: \r\n".base64_encode($text)."\r\n -->";
        }
        if (count($this->_words_page) > 0) {

            $source_sentence = array();
            if ($this->_debug) {
                $debug .= '<!-- sentences for replace: ';
            }            
            //Создаем массив исходных текстов для замены
            foreach ($this->_words_page as $n => $sentence){
                //Заменяем все сущности на символы
                $special_chars = array(
                    '&amp;' => '&',
                    '&quot;' => '"',                
                    '&#039;' => '\'',
                    '&lt;' => '<',
                    '&gt;' => '>' 
                );
                $sentence = strip_tags($sentence);
                foreach ($special_chars as $from => $to){
                    str_replace($from, $to, $sentence);
                }
                //Преобразуем все спец символы в сущности
                $sentence = htmlspecialchars($sentence);
                //Квотируем
                $sentence = preg_quote($sentence, '/');
                $replace_array = array();
            	if (preg_match_all('/(&[#a-zA-Z0-9]{2,6};)/isU', $sentence, $out)){
            		for ($i=0; $i<count($out[1]); $i++){
            			$unspec = $special_chars[$out[1][$i]];
            			$real = $out[1][$i];
            		    $replace_array[$unspec] = $real;
            		}
            	}                 
            	//Заменяем сущности на ИЛИ (сущность|символ)
            	foreach ($replace_array as $unspec => $real){
                    $sentence = str_replace($real, '(('.$real.')|('.$unspec.'))', $sentence);    
            	}
            	//Заменяем пробелы на переносы или сущности пробелов
                $source_sentences[$n] = str_replace(' ','((\s)|(&nbsp;))+',$sentence);
                
                if ($this->_debug) {
                    $debug .= $source_sentences[$n]."\r\n\r\n";
                }
            }
            
            if ($this->_debug) {
                $debug .= '-->';
            }            

            //если это первый кусок, то не будем добавлять <
            $first_part = true;
            //пустая переменная для записи
            
            if (count($source_sentences) > 0){

                $content = '';
                $open_tags = array(); //Открытые забаненые тэги
                $close_tag = ''; //Название текущего закрывающего тэга

                //Разбиваем по символу начала тега
                $part = strtok(' '.$text, '<');

                while ($part !== false){
                    //Определяем название тэга
                    if (preg_match('/(?si)^(\/?[a-z0-9]+)/', $part, $matches)){
                        //Определяем название тега
                        $tag_name = strtolower($matches[1]);
                        //Определяем закрывающий ли тэг
                        if (substr($tag_name,0,1) == '/'){
                            $close_tag = substr($tag_name, 1);
                            if ($this->_debug) {
                              $debug .= '<!-- close_tag: '.$close_tag.' -->';
                            }
                        } else {
                            $close_tag = '';
                            if ($this->_debug) {
                              $debug .= '<!-- open_tag: '.$tag_name.' -->';
                            }
                        }
                        $cnt_tags = count($open_tags);
                        //Если закрывающий тег совпадает с тегом в стеке открытых запрещенных тегов
                        if (($cnt_tags  > 0) && ($open_tags[$cnt_tags-1] == $close_tag)){
                            array_pop($open_tags);
                            if ($this->_debug) {
                                $debug .= '<!-- '.$tag_name.' - deleted from open_tags -->';
                            }
                            if ($cnt_tags-1 ==0){
                                if ($this->_debug) {
                                    $debug .= '<!-- start replacement -->';
                                }
                            }
                        }

                        //Если нет открытых плохих тегов, то обрабатываем
                        if (count($open_tags) == 0){
                            //если не запрещенный тэг, то начинаем обработку
                            if (!in_array($tag_name, $this->_filter_tags)){
                                $split_parts = explode('>', $part, 2);
                                //Перестраховываемся
                                if (count($split_parts) == 2){
                                    //Начинаем перебор фраз для замены
                                    foreach ($source_sentences as $n => $sentence){
                                        if (preg_match('/'.$sentence.'/', $split_parts[1]) == 1){
                                            $split_parts[1] = preg_replace('/'.$sentence.'/', str_replace('$','\$', $this->_words_page[$n]), $split_parts[1], 1);
                                            if ($this->_debug) {
                                                $debug .= '<!-- '.$sentence.' --- '.$this->_words_page[$n].' replaced -->';
                                            }
                                            
                                            //Если заменили, то удаляем строчку из списка замены
                                            unset($source_sentences[$n]);
                                            unset($this->_words_page[$n]);                                            
                                        }
                                    }
                                    $part = $split_parts[0].'>'.$split_parts[1];
                                    unset($split_parts);
                                }
                            } else {
                                //Если у нас запрещеный тэг, то помещаем его в стек открытых
                                $open_tags[] = $tag_name;
                                if ($this->_debug) {
                                    $debug .= '<!-- '.$tag_name.' - added to open_tags, stop replacement -->';
                                }
                            }
                        }
                    } else {
                        //Если нет названия тега, то считаем, что перед нами текст
                        foreach ($source_sentences as $n => $sentence){
                             if (preg_match('/'.$sentence.'/', $part) == 1){
                                $part = preg_replace('/'.$sentence.'/',  str_replace('$','\$', $this->_words_page[$n]), $part, 1);

                                if ($this->_debug) {
                                    $debug .= '<!-- '.$sentence.' --- '.$this->_words_page[$n].' replaced -->';
                                }
                                
                                //Если заменили, то удаляем строчку из списка замены,
                                //чтобы было можно делать множественный вызов
                                unset($source_sentences[$n]);
                                unset($this->_words_page[$n]);                                
                            }
                        }
                    }

                    //Если у нас режим дебагинга, то выводим
                    if ($this->_debug) {
                        $content .= $debug;
                        $debug = '';
                    }
                    //Если это первая часть, то не выводим <
                    if ($first_part ){
                        $content .= $part;
                        $first_part = false;
                    } else {
                        $content .= $debug.'<'.$part;
                    }
                    //Получаем следующу часть
                    unset($part);
                    $part = strtok('<');
                }
                $text = ltrim($content);
                unset($content);
            }
    } else {
        if ($this->_debug){
            $debug .= '<!-- No word`s for page -->';
        }
    }

    if ($this->_debug){
        $debug .= '<!-- END: work of replace_in_text_segment() -->';
    }

    if ($this->_is_our_bot || $this->_force_show_code || $this->_debug){
        $text = '<sape_index>'.$text.'</sape_index>';
        if (isset($this->_words['__sape_new_url__']) && strlen($this->_words['__sape_new_url__'])){
                $text .= $this->_words['__sape_new_url__'];
        }
    }

    if ($this->_debug){
        if (count($this->_words_page) > 0){
            $text .= '<!-- Not replaced: '."\r\n";
           foreach ($this->_words_page as $n => $value){
               $text .= $value."\r\n\r\n";
           }
           $text .= '-->';
        }
        
        $text .= $debug;
    }
             return $text;
    }

    /*
     * Замена слов
     *
     */
    function replace_in_page(&$buffer) {

        if (count($this->_words_page) > 0) {
            //разбиваем строку по sape_index
                 //Проверяем есть ли теги sape_index
                 $split_content = preg_split('/(?smi)(<\/?sape_index>)/', $buffer, -1);
                 $cnt_parts = count($split_content);
                 if ($cnt_parts > 1){
                     //Если есть хоть одна пара sape_index, то начинаем работу
                     if ($cnt_parts >= 3){
                         for ($i =1; $i < $cnt_parts; $i = $i + 2){
                             $split_content[$i] = $this->replace_in_text_segment($split_content[$i]);
                         }
                     }
                    $buffer = implode('', $split_content);
                     if ($this->_debug){
                         $buffer .= '<!-- Split by Sape_index cnt_parts='.$cnt_parts.'-->';
                     }
                 } else {
                     //Если не нашли sape_index, то пробуем разбить по BODY
                     $split_content = preg_split('/(?smi)(<\/?body[^>]*>)/', $buffer, -1, PREG_SPLIT_DELIM_CAPTURE);
                     //Если нашли содержимое между body
                     if (count($split_content) == 5){
                         $split_content[0] = $split_content[0].$split_content[1];
                         $split_content[1] = $this->replace_in_text_segment($split_content[2]);
                         $split_content[2] = $split_content[3].$split_content[4];
                         unset($split_content[3]);
                         unset($split_content[4]);
                         $buffer = $split_content[0].$split_content[1].$split_content[2];
                         if ($this->_debug){
                             $buffer .= '<!-- Split by BODY -->';
                         }
                     } else {
                        //Если не нашли sape_index и не смогли разбить по body
                         if ($this->_debug){
                             $buffer .= '<!-- Can`t split by BODY -->';
                         }
                     }
                 }

        } else {
            if (!$this->_is_our_bot && !$this->_force_show_code && !$this->_debug){
                $buffer = preg_replace('/(?smi)(<\/?sape_index>)/','', $buffer);
            } else {
                if (isset($this->_words['__sape_new_url__']) && strlen($this->_words['__sape_new_url__'])){
                        $buffer .= $this->_words['__sape_new_url__'];
                }
            }
            if ($this->_debug){
               $buffer .= '<!-- No word`s for page -->';
            }
        }
        return $buffer;
    }

    function _get_db_file() {
        if ($this->_multi_site) {
            return dirname(__FILE__) . '/' . $this->_host . '.words.db';
        } else {
            return dirname(__FILE__) . '/words.db';
        }
    }
    function _get_dispenser_path() {
    	return '/code_context.php?user=' . _SAPE_USER . '&host=' . $this->_host;
    }

	 function set_data($data) {
	 	$this->_words = $data;
	    if (array_key_exists($this->_request_uri, $this->_words) && is_array($this->_words[$this->_request_uri])) {
	        $this->_words_page = $this->_words[$this->_request_uri];
	    }
	 }
}


class SAPE_client {

    var $first;
    var $second;
    var $is_sape_bot = false;

    function SAPE_client($options = null) {
        if (LINKFEED_FIRST) {
            $this->first  = new Linkfeed_emulation($options);
            $this->second = new SAPE_emulation($options);
            $this->first->is_sape_bot( $this->second->is_sape_bot());
        } else {
            $this->first  = new SAPE_emulation($options);
            $this->second = new Linkfeed_emulation($options);
            $this->second->is_sape_bot( $this->first->is_sape_bot());
        }
    }

    function return_links($n = null) {
        $block = '';
        $total_first_links  = $this->first->links_count();
        $total_second_links = $this->second->links_count();
        $available_links_count = 0;

        $block .= $this->first->return_links($n);

        if (is_numeric($n)) {
            $available_links_count = $n - $total_first_links;
        }

        if ( !is_numeric($n) || $available_links_count > 0) {
            if ( $total_first_links != 0 && $total_second_links != 0 ) {
                $block .= $this->first->delimiter();
            }
            if  (!is_numeric($n)) {
               $block .= $this->second->return_links();
            } else {
               $block .= $this->second->return_links($available_links_count);
            }
        }
        return $block;
    }

}

?>
