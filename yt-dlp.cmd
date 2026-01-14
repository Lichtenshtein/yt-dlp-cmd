@ECHO OFF

:: welcome to escaping hell
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
:: endlocal

:: v0.1 2021/01/09 CirothUngol
:: original script by CirothUngol
:: 
:: v0.1 2021/01/09 CirothUngol
:: https://www.reddit.com/r/youtubedl/comments/kws98p/simple_batchfile_for_using_youtubedlexe_with
:: yt-dlp.cmd [url[.txt]] [...]
::
:: for drag'n'drop function any combination of URLs
:: and text files may be used. text files are found 
:: and processed first, then all URLs.
::
:: v3.1 2026/01/14 Lichtenshtein

:: to convert comments to readable HTML python needs to be installed
:: then you may also need to install "pip install json2html"

:: recomended ffmpeg static build with nonfree codecs
:: https://github.com/MartinEesmaa/FFmpeg-Builds

:: set terminal size (scrolling won't work without walkarouds)
:: resize terminal window before launching the script
:: or uncomment the lines below
:: MODE con: cols=120 lines=53
:: set the screen buffer size (this is a walkaroud to enable scrolling)
:: can't test because i don't have any powershell in the system right now 
:: powershell -command "&{$H=get-host;$W=$H.ui.rawui;$B=$W.buffersize;$B.width=120;$B.height=9999;$W.buffersize=$B;}"
:: set terminal color, and codepage to unicode (65001=UTF-8)
color 0f
CHCP 65001 >NUL

:: set /F needs indentation
for /f %%j in ('"prompt $H &echo on &for %%k in (1) do rem"') do set "BS=%%j"

:: build separator string of hyphens with length = COLS
:: retrieve console columns (width) by parsing 'mode con' output
:: should use local language value instead of "Columns" (type 'mode con' in cmd)
:: however this code should work for all langs (not working for me)
for /f "skip=4 tokens=2" %%k in ('mode con') do set /A COLS=%%k
:: for /f "tokens=2" %%k in ('mode con ^| findstr "Columns"') do set /A COLS=%%k
set "separator="
for /L %%I in (1,1,%COLS%) do set "separator=!separator!─"
set "padding="
for /L %%I in (1,1,%COLS%) do set "padding=!padding! "

:: color sets
FOR /F %%a in ('"prompt $E$S & echo on & FOR %%b in (1) DO rem"') DO SET "ESC=%%a"
:: STYLES
SET Underline=%ESC%[4m
SET Bold=%ESC%[1m
SET Inverse=%ESC%[7m
:: NORMAL FOREGROUND COLORS 
SET Black-n=%ESC%[30m
SET Red-n=%ESC%[31m
SET Green-n=%ESC%[32m
SET Yellow-n=%ESC%[33m
SET Blue-n=%ESC%[34m
SET Magenta-n=%ESC%[35m
SET Cyan-n=%ESC%[36m
SET White-n=%ESC%[37m
:: NORMAL BACKGROUND COLORS 
SET Black-n-b=%ESC%[40m
SET Red-n-b=%ESC%[41m
SET Green-n-b=%ESC%[42m
SET Yellow-n-b=%ESC%[43m
SET Blue-n-b=%ESC%[44m
SET Magenta-n-b=%ESC%[45m
SET Cyan-n-b=%ESC%[46m
SET White-n-b=%ESC%[47m
:: STRONG FOREGROUND COLORS 
SET Black-s=%ESC%[90m
SET Red-s=%ESC%[91m
SET Green-s=%ESC%[92m
SET Yellow-s=%ESC%[93m
SET Blue-s=%ESC%[94m
SET Magenta-s=%ESC%[95m
SET Cyan-s=%ESC%[96m
SET White-s=%ESC%[97m
:: STRONG FOREGROUND COLORS 
SET ColorOff=%ESC%[0m
:: example
:: ECHO An attempt to show a word as %Underline%yellow%ColorOff% color in a sentence...

:: temporary register exes required for plugins to system PATH
SET "PATH=%PATH%;B:\rsgain;B:\aacgain;B:\vorbisgain;B:\mp3gain;"

:: set target folder and exe locations
SET       TARGET_FOLDER=F:\Temp
SET        YTDLP_FOLDER=D:\yt-dlp
SET        ARCHIVE_PATH=%YTDLP_FOLDER%\archive.txt
SET          YTDLP_PATH=%YTDLP_FOLDER%\yt-dlp.exe
SET        COOKIES_PATH=%YTDLP_FOLDER%\cookies.txt
SET  DOWNLOAD_LIST_PATH=%TEMP%\downloads.txt
SET  SPLITTER_LIST_PATH=%TEMP%\splitter.txt
SET            LOG_PATH=%TEMP%\yt-dlp-log.txt
SET         FFMPEG_PATH=D:\ffmpeg\ffmpeg.exe
SET         PYTHON_PATH=D:\Python313\python.exe
SET     JS_RUNTIME_NAME=node
SET     JS_RUNTIME_PATH=D:\js_runtime\nodejs\node.exe
REM SET     JS_RUNTIME_NAME=deno
REM SET     JS_RUNTIME_PATH=D:\js_runtime\deno\deno.exe
SET   AUDIO_PLAYER_PATH=D:\Aimp\Aimp.exe
SET   VIDEO_PLAYER_PATH=D:\PotPlayer\PotPlayerMini.exe
SET          ARIA2_PATH=D:\aria2c\aria2c.exe
SET            SED_PATH=D:\git-for-windows\usr\bin\sed.exe
SET             TR_PATH=D:\git-for-windows\usr\bin\tr.exe
SET           GREP_PATH=D:\git-for-windows\usr\bin\grep.exe
SET           HEAD_PATH=D:\git-for-windows\usr\bin\head.exe
SET          PASTE_PATH=D:\paste\paste.exe
SET      MOREUTILS_PATH=D:\moreutils-go\moreutils.exe
SET            TEE_PATH=D:\git-for-windows\usr\bin\tee.exe
:: currently not used
:: SET          ICONV_PATH=D:\git-for-windows\usr\bin\iconv.exe
:: SET           TAIL_PATH=D:\git-for-windows\usr\bin\tail.exe
:: SET       TRUNCATE_PATH=D:\git-for-windows\usr\bin\truncate.exe
:: SET       PARALLEL_PATH=D:\parallel\rust-parallel.exe
:: set            opustags=D:\opustags\opustags.exe
:: set aria args
SET             USEARIA=
SET           ARIA_ARGS=--conf-path="D:\aria2c\aria2.conf"
:: sed special commands file
SET        SED_COMMANDS=%YTDLP_FOLDER%\sed.txt
:: set yt-dlp common options
SET         SPEED_LIMIT=8096K
REM SET             RETRIES=infinite
SET             RETRIES=99
SET    FRAGMENT_RETRIES=55
SET         BUFFER_SIZE=5M
:: tip: paste multiple URL at a time to download in parallel (not tested)
SET             THREADS=3
SET        THUMB_FORMAT=jpg
SET      THUMB_COMPRESS=3
SET           SUB_LANGS=en,-live_chat
SET          SUB_FORMAT=srt/vtt/ass/best
REM player_skip=webpage,configs,js,initial_data
REM player_client=default,web_creator,web_safari,web,-tv,-mweb
REM player-client=default,-tv_simply
REM player_client=default,-tv
REM player_js_version=actual
REM player-client=-default,android_vr
SET      EXTRACTOR_ARGS=player_client=android_vr,web_safari,tv
SET          USER_AGENT=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0
SET     YTDLP_CACHE_DIR=%TEMP%\yt-dlp
SET    SPONSORBLOCK_OPT=sponsor,preview
:: i.e. http://proxy-ip:port; socks5://localhost:port
SET               PROXY=
:: default/never/two-letter ISO 3166-2 country code/IP block in CIDR notation
SET          GEO-BYPASS=1.138.171.50/24
:: this used for tests
SET reasonable-timeouts=
REM SET               DEBUG= -v -s --keep-video
SET       RETRIES_SLEEP=1.0
:: note: minimizing --extractor-arg "youtube:playback_wait=0.3" value breaks CustomChapters plugin, won't be able to extract chapters
SET               SLEEP=--socket-timeout 30 --min-sleep-interval 0.7 --sleep-subtitles 3 --sleep-requests 0.75 --sleep-interval 3.5 --max-sleep-interval 7 --retry-sleep %RETRIES_SLEEP%
:: plugins settings
SET       CHAPTERS_PATH=%YTDLP_FOLDER%\chapters.txt
SET  use_pl_splitandtag=
SET   format-title-auto=
SET         SPLIT_REGEX=%%title
SET    PYTHONIOENCODING=utf-8
SET          PYTHONUTF8=1
:: set ffmpeg common options
SET FFMPEG_THUMB_FORMAT=mjpeg
SET       AUDIO_BITRATE=130
SET AUDIO_SAMPLING_RATE=44100
SET         VOLUME_GAIN=2
SET              CUTOFF=20000
SET   SILENCE_THRESHOLD=30
SET            LOUDNESS=10
SET      FFMPEG_FILTERS=%YTDLP_FOLDER%\filters_complex.txt
SET                CROP='if^^^^^^^(gt^^^^^^^(ih,iw^^^^^^^),iw,ih^^^^^^^)':'if^^^^^^^(gt^^^^^^^(iw,ih^^^^^^^),ih,iw^^^^^^^)'
SET             COMPAND=compand=attacks=0:points=-80/-169 -54/-80 -49.5/-64.6 -41.1/-41.1 -25.8/-15 -10.8/-4.5 0/0 20/8.3
SET        FIREQUALIZER=firequalizer=gain='cubic_interpolate^^^^^^^(f^^^^^^^)':delay=0.027:accuracy=1:wfunc=hann:gain_entry='entry^^^^^^^(31,%VOLUME_GAIN%^^^^^^^);entry^^^^^^^(40,%VOLUME_GAIN%^^^^^^^);entry^^^^^^^(41,%VOLUME_GAIN%^^^^^^^);entry^^^^^^^(50,%VOLUME_GAIN%^^^^^^^);entry^^^^^^^(100,%VOLUME_GAIN%^^^^^^^);entry^^^^^^^(200,%VOLUME_GAIN%^^^^^^^);entry^^^^^^^(392,%VOLUME_GAIN%^^^^^^^);entry^^^^^^^(523,%VOLUME_GAIN%^^^^^^^)':scale=linlog
SET       SILENCEREMOVE=silenceremove=start_periods=1:stop_periods=-1:start_threshold=-%SILENCE_THRESHOLD%dB:detection=peak:stop_threshold=-%SILENCE_THRESHOLD%dB:detection=peak:start_silence=2:stop_silence=2
SET            LOUDNORM=dynaudnorm=m=%LOUDNESS%
SET                 PAN=pan=stereo^^^^^^^|c0=0.5*c2+0.707*c0+0.707*c4+0.5*c3^^^^^^^|c1=0.5*c2+0.707*c1+0.707*c5+0.5*c3
SET           ARESAMPLE=aresample=resampler=soxr:out_sample_rate=%AUDIO_SAMPLING_RATE%:precision=28
SET     ANLMDN_DENOISING=anlmdn=s=0.0001:p=0.01:m=15,
:: if defined will create folders for each text list entered (CirothUngol's)
SET       MAKE_LIST_DIR=
:: capture errorlevel and display warning if non-zero for yt-dlp
SET             APP_ERR=%ERRORLEVEL%
:: finding out what aac encoder ffmpeg version supports
"%FFMPEG_PATH%" -encoders -hide_banner | "%GREP_PATH%" -wq "aac_at" >nul 2>&1
if %errorlevel% equ 0 (SET ENCODER=aac_at) ELSE (
"%FFMPEG_PATH%" -encoders -hide_banner | "%GREP_PATH%" -wq "libfdk_aac" >nul 2>&1
if %errorlevel% equ 0 (SET ENCODER=libfdk_aac -afterburner 1) ELSE (SET ENCODER=aac))

:: set yt-dlp.exe commandline options, all options MUST begin with a space
:: name shorthand: %~d0=D:,%~p0=\path\to\,%~n0=name,%~x0=.ext,%~f0=%~dpnx0
:: remember to double percentage signs when used as output in batch files

::
::
:: DRAG AND DROP PRESET
::
::

:: DRAG AND DROP DEFAULT PRESET
SET  OutTemplate= --output "%TARGET_FOLDER%\%%(uploader)s\%%(title)s.%%(ext)s"
SET      Options=%DEBUG% --ignore-config --js-runtimes "%JS_RUNTIME_NAME%:%JS_RUNTIME_PATH%" --extractor-args "youtube:%EXTRACTOR_ARGS%"
SET      Network= --add-headers "User-Agent:%USER_AGENT%"
SET  GeoRestrict= --xff "%GEO-BYPASS%"
SET       Select= --no-download-archive --compat-options no-youtube-unavailable-videos
IF DEFINED USEARIA (
SET     Download= --downloader "%ARIA2_PATH%" --downloader-args "aria2c: %ARIA_ARGS%" --compat-options no-external-downloader-progress
) ELSE (
SET     Download= --limit-rate %SPEED_LIMIT% --retries %RETRIES% --fragment-retries %FRAGMENT_RETRIES% --buffer-size %BUFFER_SIZE% --concurrent-fragments %THREADS%
)
SET Sponsorblock= --no-sponsorblock
SET   FileSystem= --no-mtime --ffmpeg-location "%FFMPEG_PATH%"
SET    Thumbnail= --embed-thumbnail --convert-thumbnail %THUMB_FORMAT% --postprocessor-args "ThumbnailsConvertor:-q:v %THUMB_COMPRESS%"
SET    Verbosity= --color always --console-title --progress --progress-template ["download] Progress":" %%(progress._percent_str)s, Speed: %%(progress._speed_str)s, Elapsed: %%(progress._elapsed_str)s, Time Remaining: %%(progress._eta_str|0)s/s"
IF DEFINED reasonable-timeouts (
SET  WorkArounds= %SLEEP%
) ELSE (
SET  WorkArounds=
)
SET       Format= --format "bestvideo[height<=480][ext=mp4]+bestaudio/best" -S "fps:30,channels:2"
SET     Subtitle= --sub-format "%SUB_FORMAT%" --sub-langs "%SUB_LANGS%" --compat-options no-live-chat
SET     Comments=
SET Authenticate=
SET    AdobePass=
SET   PreProcess= --parse-metadata "%%(epoch>%%Y-%%m-%%d)s:%%(meta_download_date)s" --parse-metadata "%%(album,playlist_title,channel)s:%%(meta_album)s" --parse-metadata "%%(album_artist,album_artists,uploader)s:%%(meta_album_artist)s" --parse-metadata "%%(artist,artists.0,creator,uploader)s:%%(meta_artist)s" --parse-metadata "%%(average_rating)s:%%(meta_rating)s" --parse-metadata "%%(composer,composers)s:%%(meta_composer)s" --parse-metadata "%%(disc_number)s:%%(meta_disc)s" --parse-metadata "%%(dislike_count)s:%%(meta_dislikes)s" --parse-metadata "%%(genre,genres)s:%%(meta_genre)s" --parse-metadata "%%(like_count)s:%%(meta_likes)s" --parse-metadata "%%(playlist_index,track_number,playlist_autonumber|01)s:%%(meta_track)s" --parse-metadata "%%(release_date>%%Y-%%m-%%d,release_year,upload_date>%%Y-%%m-%%d)s:%%(meta_date)s" --parse-metadata "%%(view_count)s:%%(meta_views)s" --parse-metadata ":(?P<meta_longdescription>)" --parse-metadata ":(?P<meta_synopsis>)" --parse-metadata ":(?P<meta_purl>)" --parse-metadata "webpage_url:%%(meta_www)s" --replace-in-metadata meta_album_artist " - Topic" "" --replace-in-metadata meta_date "^NA$" "" --replace-in-metadata meta_rating "^NA$" "" --replace-in-metadata meta_views "^NA$" "" --replace-in-metadata meta_likes "^NA$" "" --replace-in-metadata meta_dislikes "^NA$" "" --replace-in-metadata meta_disc "^NA$" "" --replace-in-metadata meta_composer "^NA$" "" --replace-in-metadata meta_album "%%(channel)s" "%%(channel)s Videos" --replace-in-metadata meta_album "^NA$" "" --replace-in-metadata meta_genre "^NA$" "" --replace-in-metadata title "/" "⁄" --replace-in-metadata title ":" "꞉" --replace-in-metadata album "/" "⁄" --replace-in-metadata album ":" "꞉"
SET  PostProcess= --embed-metadata --embed-chapters --embed-subs --compat-options no-attach-info-json

::
::
:: DRAG AND DROP LINKS TO BAT FUNCTIONS
::
::

:: capture commandline, add batch folder to path, create and enter target
SET source=%*
CALL SET "PATH=%~dp0;%%PATH:%~dp0;=%%"
MD "%TARGET_FOLDER%" >NUL 2>&1
PUSHD "%TARGET_FOLDER%"

:getURL-drag -- main loop
cls
:: if no drag and drop files - go to menu
if "%~1"=="" GOTO :getURL
:: prompt for source, exit if empty, call routines, loop
IF DEFINED Downloaded-Drag (
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  COLLECTED ERRORS!padding:~1,-22!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
FOR /f "delims=" %%j IN ('type "%LOG_PATH%"') DO ECHO %%j
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Done. Press any key.!padding:~1,-26!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
PAUSE >nul
IF EXIST "%LOG_PATH%" del /f /q "%LOG_PATH%" >nul 2>&1
)
IF NOT DEFINED source (
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  ENTER SOURCE!padding:~1,-18!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /P URL=%BS%   %Cyan-n%› %ColorOff% 
)
IF NOT DEFINED source POPD & EXIT /B %APP_ERR%
CALL :getLST-drag %source%
CALL :doYTDL-drag %source%
SET source=
GOTO :getURL-drag

:getLST-drag url[.txt] [...]
:: if source <> file & 2nd paramer is empty then exit, else left-shift and loop
IF NOT EXIST "%~1" IF ""=="%~2" ( EXIT /B 0 ) ELSE SHIFT & GOTO :getLST-drag
:: remove file from source, display filename, call yt-dlp
CALL SET source=%%source:%1=%%
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  Fetching URLs...!padding:~1,-22!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
:: create new target using list.txt filename and enter new target
IF DEFINED MAKE_LIST_DIR MD "%TARGET_FOLDER%\%~n1" >NUL 2>&1
IF DEFINED MAKE_LIST_DIR PUSHD "%TARGET_FOLDER%\%~n1"
:: clean a .URL file from innapropriate lines 
:: drag link from browser to disk to download .URL
"%SED_PATH%" -i -e '/InternetShortcut/d';'s/URL=//g';'s/^&.*//' %1 >nul 2>&1
REM "%TRUNCATE_PATH%" -s -1 %1 >NUL 2>&1
"%TR_PATH%" -d "\n" %1 >NUL 2>&1
FOR /F "usebackq tokens=*" %%A IN ("%~1") DO CALL :doYTDL-drag "%%~A"
:: return to target folder, left-shift parameters, and loop
IF DEFINED MAKE_LIST_DIR POPD
SHIFT
GOTO :getLST-drag

:getURL
SET temp_file1=%TEMP%\clipboard.txt
SET temp_file2=%TEMP%\clipboard2.txt
:: get clipboard content to file
"%PASTE_PATH%" > "%temp_file1%"
:: find out if clipboard content is a link
findstr /R "^.https://.* ^https://.* .[a-zA-Z]:\\.*" "%temp_file1%" >nul 2>&1
if %errorlevel% equ 0 (SET YAY=1) ELSE (SET YAY=)
:: if true try deleting double quotes because script will crash before it even starts
:: delete & and everything after (may break links). mostly ok for youtube
:: sed unable to edit files inplace if sed and file are on different filesystems (or drives)
:: delete spaces, delete new lines, delete newline symbol that sed brings every time
:: copy everything back to clipboard, and finally set a 'clipboard' variable that is finally settable
:: 12 hours of guessing what was (and still) ruining all the echo formating here and there (color, etc). no clue
IF DEFINED YAY (
"%SED_PATH%" -e 's/^&.*//';'s/\"//g';'s/\"$//g';'s/[ \t]*$//' "%temp_file1%" > "%temp_file2%"
REM "%TRUNCATE_PATH%" -s -1 "%temp_file1%"
"%TR_PATH%" -d "\n" < "%temp_file2%" > "%temp_file1%"
type "%temp_file1%" | clip
SET /p clipboard=<"%temp_file1%"
IF EXIST "%temp_file1%" del /f /q "%temp_file1%" >nul 2>&1
IF EXIST "%temp_file2%" del /f /q "%temp_file2%" >nul 2>&1
)
IF "%YAY%"=="1" (
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  ENTER SOURCE URL ^(or enter "q" to quick-download URL from clipboard; "a" for quick-download audio^)!padding:~1,-104!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /P URL=%BS%   %Cyan-n%› %ColorOff% 
IF NOT DEFINED URL EXIT /B %APP_ERR%
IF "!URL!"=="q" (SET URL=!clipboard!& GOTO :doYTDL-quick) ELSE (
IF "!URL!"=="a" (SET URL=!clipboard!& GOTO :doYTDL-preset-quick) ELSE (GOTO :start))
) ELSE (
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  ENTER SOURCE URL!padding:~1,-22!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /P URL=%BS%   %Cyan-n%› %ColorOff% 
IF NOT DEFINED URL EXIT /B %APP_ERR%
GOTO :start)

:start
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  MENU!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╯%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Download Audio
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  Download Video
ECHO %Blue-s%│%ColorOff%  %Cyan-s%3%ColorOff%  Download From List
ECHO %Blue-s%│%ColorOff%  %Cyan-s%4%ColorOff%  Download Manually
ECHO %Blue-s%│%ColorOff%  %Cyan-s%5%ColorOff%  Download Subtitles Only
ECHO %Blue-s%│%ColorOff%  %Cyan-s%6%ColorOff%  Download Comments Only
ECHO %Blue-s%│%ColorOff%  %Cyan-s%7%ColorOff%  Split Sections/Chapters
ECHO %Blue-s%│%ColorOff%  %Cyan-s%8%ColorOff%  Stream To Player
ECHO %Blue-s%┝%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%e%ColorOff%  %Magenta-n%Enter URL%ColorOff%	%Yellow-s%v%ColorOff%  Version Info!padding:~1,-31!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%s%ColorOff%  Settings	%Yellow-s%c%ColorOff%  Extractor Descriptions!padding:~1,-41!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%u%ColorOff%  Update	%Yellow-s%x%ColorOff%  Error Info!padding:~1,-29!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Enter your choice: 
IF "%choice%"=="1" IF NOT DEFINED URL (SET URL-Hook-Audio=1& GOTO :getURL-continue) ELSE (GOTO :select-format-audio)
IF "%choice%"=="2" IF NOT DEFINED URL (SET URL-Hook-Video=1& GOTO :getURL-continue) ELSE (GOTO :select-format-video)
IF "%choice%"=="3" IF NOT DEFINED URL (SET URL-Hook-List=1& GOTO :getURL-continue) ELSE (GOTO :select-download-list)
IF "%choice%"=="4" IF NOT DEFINED URL (SET URL-Hook-Manual=1& GOTO :getURL-continue) ELSE (GOTO :select-format-manual)
IF "%choice%"=="5" IF NOT DEFINED URL (SET URL-Hook-Subs=1& GOTO :getURL-continue) ELSE (GOTO :select-preset-subs)
IF "%choice%"=="6" IF NOT DEFINED URL (SET URL-Hook-Comments=1& GOTO :getURL-continue) ELSE (GOTO :select-preset-comments)
IF "%choice%"=="7" IF NOT DEFINED URL (SET URL-Hook-Sections=1& GOTO :getURL-continue) ELSE (GOTO :select-preset-sections)
IF "%choice%"=="8" IF NOT DEFINED URL (SET URL-Hook-Stream=1& GOTO :getURL-continue) ELSE (GOTO :select-format-stream)
IF "%choice%"=="e" GOTO :getURL-re-enter
IF "%choice%"=="s" GOTO :settings
IF "%choice%"=="u" GOTO :update
IF "%choice%"=="v" GOTO :info
IF "%choice%"=="c" GOTO :extractors
IF "%choice%"=="x" GOTO :error-info
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :start

:extractors
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  EXTRACTORS INFO!padding:~1,-21!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
"%YTDLP_PATH%" --extractor-descriptions
ECHO.
IF %APP_ERR% NEQ 0 (
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  %Red-s%ERROR%ColorOff%: yt-dlp ErrorLevel is %Cyan-s%%APP_ERR%%ColorOff%.
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
)
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│  %Green-s%•%ColorOff%  Press any key!padding:~1,-19!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
PAUSE >nul
GOTO :start

:getURL-re-enter
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  ENTER SOURCE URL!padding:~1,-22!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /P URL=%BS%   %Cyan-n%› %ColorOff% 
IF NOT DEFINED URL EXIT /B %APP_ERR%
IF "%Downloaded-Audio%"=="1" (
GOTO :continue
) ELSE (IF "%Downloaded-Video%"=="1" (
GOTO :continue
) ELSE (IF "%Downloaded-Manual%"=="1" (
GOTO :continue
) ELSE (IF "%Downloaded-Manual-Single%"=="1" (
GOTO :continue
) ELSE (IF "%Downloaded-Comments%"=="1" (
GOTO :continue
) ELSE (IF "%Downloaded-Subs%"=="1" (
GOTO :continue
) ELSE (IF "%Downloaded-Stream%"=="1" (
GOTO :continue
) ELSE (IF "%Downloaded-Sections%"=="1" (
GOTO :continue
) ELSE (IF "%Downloaded-Quick%"=="1" (
GOTO :continue
) ELSE (
GOTO :start
)))))))))

:settings
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  SETTINGS!padding:~1,-14!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╯%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Cookies
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  Downloader
ECHO %Blue-s%│%ColorOff%  %Cyan-s%3%ColorOff%  Plugins
ECHO %Blue-s%│%ColorOff%  %Cyan-s%4%ColorOff%  Geo-Bypass
ECHO %Blue-s%│%ColorOff%  %Cyan-s%5%ColorOff%  Proxy
ECHO %Blue-s%│%ColorOff%  %Cyan-s%6%ColorOff%  Duration Filter
ECHO %Blue-s%│%ColorOff%  %Cyan-s%7%ColorOff%  Date Filter
ECHO %Blue-s%│%ColorOff%  %Cyan-s%8%ColorOff%  Behaviour On Errors
ECHO %Blue-s%│%ColorOff%  %Cyan-s%9%ColorOff%  Send Long Videos To Splitter
ECHO %Blue-s%│%ColorOff% %Cyan-s%10%ColorOff%  Auto Title Formating
ECHO %Blue-s%│%ColorOff% %Cyan-s%11%ColorOff%  FFmpeg Filters
ECHO %Blue-s%│%ColorOff% %Cyan-s%12%ColorOff%  Reasonable Timeouts
ECHO %Blue-s%│%ColorOff% %Cyan-s%13%ColorOff%  Debug
ECHO %Blue-s%┝%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Enter your choice: 
IF "%choice%"=="1" GOTO :cookies
IF "%choice%"=="2" GOTO :aria
IF "%choice%"=="3" GOTO :plugins
IF "%choice%"=="4" GOTO :geo-bypass
IF "%choice%"=="5" GOTO :proxy
IF "%choice%"=="6" GOTO :set-duration-filter
IF "%choice%"=="7" GOTO :set-date-filter
IF "%choice%"=="8" GOTO :playlist-error
IF "%choice%"=="9" GOTO :smart-splitter
IF "%choice%"=="10" GOTO :format-title-auto
IF "%choice%"=="11" GOTO :ffmpeg-filters
IF "%choice%"=="12" GOTO :timeouts
IF "%choice%"=="13" GOTO :debug
IF "%choice%"=="w" GOTO :start
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :settings

:debug
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  Enable Debugging ^(verbose log + simulative downloads^)!padding:~1,-59!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╯%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Enable
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  %Yellow-n%Disable%ColorOff% %Blue-s%^(default^)%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Enable debug? 
IF "%choice%"=="1" SET "DEBUG= -v -s --keep-video"& GOTO :settings
IF "%choice%"=="2" SET DEBUG=& GOTO :settings
IF "%choice%"=="w" GOTO :settings
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :debug

:timeouts
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  Reasonable Timeouts ^(some necessary measures to prevent YouTube from blocking you^)!padding:~1,-88!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╯%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Enable %Blue-s%^(default^)%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  %Yellow-n%Disable%ColorOff% 
ECHO %Blue-s%┝%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Enable request timeouting? 
IF "%choice%"=="1" SET reasonable-timeouts=1& IF DEFINED ContinueHook (GOTO :continue) ELSE (GOTO :settings)
IF "%choice%"=="2" SET reasonable-timeouts=& IF DEFINED ContinueHook (GOTO :continue) ELSE (GOTO :settings)
IF "%choice%"=="w" IF DEFINED ContinueHook (GOTO :continue) ELSE (GOTO :settings)
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :timeouts

:format-title-auto
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  Auto Title Formating ^(i.e. interpret Title as "Artist - Title" if found " - " in it^)!padding:~1,-90!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╯%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Enable %Blue-s%^(default^)%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  %Yellow-n%Disable%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Enable Auto Title Formating? 
IF "%choice%"=="1" SET format-title-auto=1& GOTO :settings
IF "%choice%"=="2" SET format-title-auto=& GOTO :settings
IF "%choice%"=="w" GOTO :settings
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :format-title-auto

:ffmpeg-filters
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  FFmpeg Filters!padding:~1,-20!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╯%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Denoising Filter
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  Loudnorm Filter
ECHO %Blue-s%│%ColorOff%  %Cyan-s%3%ColorOff%  Silence Remover
ECHO %Blue-s%│%ColorOff%  %Cyan-s%4%ColorOff%  Firequalizer
ECHO %Blue-s%│%ColorOff%  %Cyan-s%5%ColorOff%  Compand Filter
ECHO %Blue-s%│%ColorOff%  %Cyan-s%6%ColorOff%  Pan Mixer
ECHO %Blue-s%│%ColorOff%  %Cyan-s%7%ColorOff%  Sox Resampler
ECHO %Blue-s%┝%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Enter your choice: 
IF "%choice%"=="1" GOTO :ffmpeg-anlmdn
IF "%choice%"=="2" GOTO :ffmpeg-loudnorm
IF "%choice%"=="3" GOTO :ffmpeg-silence
IF "%choice%"=="4" GOTO :ffmpeg-firequalizer
IF "%choice%"=="5" GOTO :ffmpeg-compand
IF "%choice%"=="6" GOTO :ffmpeg-mixer
IF "%choice%"=="7" GOTO :ffmpeg-sox
IF "%choice%"=="w" GOTO :start
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :ffmpeg-filters

:ffmpeg-sox
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  Sox Resampler!padding:~1,-19!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╯%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Enable %Blue-s%^(default^)%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  %Yellow-n%Disable%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Enable Sox Resampler? 
IF "%choice%"=="1" SET "ARESAMPLE=%ARESAMPLE%" & GOTO :ffmpeg-filters
IF "%choice%"=="2" SET ARESAMPLE=& GOTO :ffmpeg-filters
IF "%choice%"=="w" GOTO :ffmpeg-filters
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :ffmpeg-sox

:ffmpeg-mixer
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  Pan Filter ^(downmixes multi-channel audio to stereo^)!padding:~1,-58!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╯%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Enable %Blue-s%^(default^)%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  %Yellow-n%Disable%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Enable Pan filter? 
IF "%choice%"=="1" SET "PAN=%PAN%" & GOTO :ffmpeg-filters
IF "%choice%"=="2" SET PAN=& GOTO :ffmpeg-filters
IF "%choice%"=="w" GOTO :ffmpeg-filters
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :ffmpeg-mixer

:ffmpeg-compand
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  Compand!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╯%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Enable %Blue-s%^(default^)%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  %Yellow-n%Disable%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Enable Compand filter? 
IF "%choice%"=="1" SET "COMPAND=%COMPAND%" & GOTO :ffmpeg-filters
IF "%choice%"=="2" SET COMPAND=& GOTO :ffmpeg-filters
IF "%choice%"=="w" GOTO :ffmpeg-filters
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :ffmpeg-compand

:ffmpeg-firequalizer
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  Firequalizer!padding:~1,-18!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╯%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Enable %Blue-s%^(default^)%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  %Yellow-n%Disable%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Enable Firequalizer filter? 
IF "%choice%"=="1" SET "FIREQUALIZER=%FIREQUALIZER%" & GOTO :ffmpeg-filters
IF "%choice%"=="2" SET FIREQUALIZER=& GOTO :ffmpeg-filters
IF "%choice%"=="w" GOTO :ffmpeg-filters
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :ffmpeg-firequalizer

:ffmpeg-silence
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  Silence Remover!padding:~1,-21!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╯%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Enable %Blue-s%^(default^)%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  %Yellow-n%Disable%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Enable Silence Remove filter? 
IF "%choice%"=="1" SET "SILENCEREMOVE=%SILENCEREMOVE%" & GOTO :ffmpeg-filters
IF "%choice%"=="2" SET SILENCEREMOVE=& GOTO :ffmpeg-filters
IF "%choice%"=="w" GOTO :ffmpeg-filters
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :ffmpeg-silence

:ffmpeg-loudnorm
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  Loudness level normalization!padding:~1,-34!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╯%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Enable %Blue-s%^(default^)%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  %Yellow-n%Disable%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Enable loudnorm filter? 
IF "%choice%"=="1" SET "LOUDNORM=%LOUDNORM%" & GOTO :ffmpeg-filters
IF "%choice%"=="2" SET LOUDNORM=& GOTO :ffmpeg-filters
IF "%choice%"=="w" GOTO :ffmpeg-filters
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :ffmpeg-loudnorm

:ffmpeg-anlmdn
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  Anlmdn denoising filter ^(%Bold%%Blue-s%*VERY*%ColorOff%%ColorOff% slow^)!padding:~1,-43!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╯%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Enable
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  %Yellow-n%Disable%ColorOff% %Blue-s%^(default^)%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Enable Anlmdn filter? 
IF "%choice%"=="1" SET "ANLMDN_DENOISING=%ANLMDN_DENOISING%" & GOTO :ffmpeg-filters
IF "%choice%"=="2" SET ANLMDN_DENOISING=& GOTO :ffmpeg-filters
IF "%choice%"=="w" GOTO :ffmpeg-filters
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :ffmpeg-anlmdn

:smart-splitter
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  Smart Splitter ^(treat long videos (^>14mins) in playlists as Full Albums and send them to splitter^)!padding:~1,-104!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╯%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Enable
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  %Yellow-n%Disable%ColorOff% 
ECHO %Blue-s%┝%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Enable Smart Splitter? 
IF "%choice%"=="1" SET smart_splitter=1& SET duration_filter=1& SET "duration_filter_1=<840"& IF DEFINED ContinueHook (GOTO :continue) ELSE (GOTO :settings)
IF "%choice%"=="2" SET smart_splitter=& SET duration_filter=& SET duration_filter_1=&ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%& ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Disabled. Please re-set your Duration Filters.!padding:~1,-52!%Red-s%│%ColorOff%& ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%& timeout /t 2 >nul &IF DEFINED ContinueHook (GOTO :continue) ELSE (GOTO :settings)
IF "%choice%"=="w" IF DEFINED ContinueHook (GOTO :continue) ELSE (GOTO :settings)
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :smart-splitter

:select-download-list
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  DOWNLOAD FROM TEXT LIST!padding:~1,-29!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Audio List
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  Audio List + Only New
ECHO %Blue-s%│%ColorOff%  %Cyan-s%3%ColorOff%  Audio List + Crop Thumbnail
ECHO %Blue-s%│%ColorOff%  %Cyan-s%4%ColorOff%  Audio List + Crop Thumbnail + Only New
ECHO %Blue-s%│%ColorOff%  %Cyan-s%5%ColorOff%  Audio List + Crop Thumbnail + Interpret Title As "Artist - Title"
ECHO %Blue-s%│%ColorOff%  %Cyan-s%6%ColorOff%  Audio List + Crop Thumbnail + Interpret Title As "Artist - Title" + Only New
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%7%ColorOff%  Video List
ECHO %Blue-s%│%ColorOff%  %Cyan-s%8%ColorOff%  Video List + Only New
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%9%ColorOff%  Split Audio From List
ECHO %Blue-s%│%ColorOff% %Cyan-s%10%ColorOff%  Split Audio From List + Only New
ECHO %Blue-s%│%ColorOff% %Cyan-s%11%ColorOff%  Split Audio From List + Crop Thumbnail
ECHO %Blue-s%│%ColorOff% %Cyan-s%12%ColorOff%  Split Audio From List + Crop Thumbnail + Only New
ECHO %Blue-s%│%ColorOff% %Cyan-s%13%ColorOff%  Split Audio From List + Crop Thumbnail + Interpret Title As "Artist - Album"
ECHO %Blue-s%│%ColorOff% %Cyan-s%14%ColorOff%  Split Audio From List + Crop Thumbnail + Interpret Title As "Artist - Album" + Only New
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
ECHO %Blue-s%│%ColorOff% %Cyan-s%15%ColorOff%  Split Video From List
ECHO %Blue-s%│%ColorOff% %Cyan-s%16%ColorOff%  Split Video From List + Only New
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%e%ColorOff%  Export Huge Playlist To Download List!padding:~1,-43!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Select preset: 
IF "%choice%"=="1" SET DownloadList=1& IF "%use_pl_replaygain%"=="1" (SET ReplayGainPreset=1& GOTO :select-format-audio) ELSE (GOTO :select-format-audio)
IF "%choice%"=="2" SET DownloadList=1& SET OnlyNew=1& IF "%use_pl_replaygain%"=="1" (SET ReplayGainPreset=1& GOTO :select-format-audio) ELSE (GOTO :select-format-audio)
IF "%choice%"=="3" SET DownloadList=1& SET CropThumb=1& IF "%use_pl_replaygain%"=="1" (SET ReplayGainPreset=1& GOTO :select-format-audio) ELSE (GOTO :select-format-audio)
IF "%choice%"=="4" SET DownloadList=1& SET CropThumb=1& SET OnlyNew=1& IF "%use_pl_replaygain%"=="1" (SET ReplayGainPreset=1& GOTO :select-format-audio) ELSE (GOTO :select-format-audio)
IF "%choice%"=="5" SET DownloadList=1& SET CropThumb=1& SET FormatTitle=1& IF "%use_pl_replaygain%"=="1" (SET ReplayGainPreset=1& GOTO :select-format-audio) ELSE (GOTO :select-format-audio)
IF "%choice%"=="6" SET DownloadList=1& SET CropThumb=1& SET FormatTitle=1& SET OnlyNew=1& IF "%use_pl_replaygain%"=="1" (SET ReplayGainPreset=1& GOTO :select-format-audio) ELSE (GOTO :select-format-audio)
IF "%choice%"=="7" SET DownloadList=1& GOTO :select-format-video
IF "%choice%"=="8" SET DownloadList=1& SET OnlyNew=1& GOTO :select-format-video
:: ReplayGain won't apply on splitted files but i'll leave in like that
IF "%choice%"=="9" SET DownloadList=2& IF "%use_pl_replaygain%"=="1" (SET ReplayGainPreset=4& GOTO :select-format-audio) ELSE (GOTO :select-format-audio)
IF "%choice%"=="10" SET DownloadList=2& SET OnlyNew=1& IF "%use_pl_replaygain%"=="1" (SET ReplayGainPreset=4& GOTO :select-format-audio) ELSE (GOTO :select-format-audio)
IF "%choice%"=="11" SET DownloadList=2& SET CropThumb=1& IF "%use_pl_replaygain%"=="1" (SET ReplayGainPreset=4& GOTO :select-format-audio) ELSE (GOTO :select-format-audio)
IF "%choice%"=="12" SET DownloadList=2& SET CropThumb=1& SET OnlyNew=1& IF "%use_pl_replaygain%"=="1" (SET ReplayGainPreset=4& GOTO :select-format-audio) ELSE (GOTO :select-format-audio)
IF "%choice%"=="13" SET DownloadList=2& SET CropThumb=1& SET FormatTitle=1& IF "%use_pl_replaygain%"=="1" (SET ReplayGainPreset=4& GOTO :select-format-audio) ELSE (GOTO :select-format-audio)
IF "%choice%"=="14" SET DownloadList=2& SET CropThumb=1& SET FormatTitle=1& SET OnlyNew=1& IF "%use_pl_replaygain%"=="1" (SET ReplayGainPreset=4& GOTO :select-format-audio) ELSE (GOTO :select-format-audio)
IF "%choice%"=="15" SET DownloadList=2& GOTO :select-format-video
IF "%choice%"=="16" SET DownloadList=2& SET OnlyNew=1& GOTO :select-format-video
IF "%choice%"=="e" GOTO :playlist-export
IF "%choice%"=="w" GOTO :start
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :select-download-list

:playlist-export
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  ENTER PLAYLIST URL!padding:~1,-24!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
IF DEFINED ContinueHook (
SET PLAYLIST_URL=%URL%
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Downloading from text list enabled!padding:~1,-40!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
SET DownloadList=1
) ELSE (
SET /P PLAYLIST_URL=%BS%   %Cyan-n%› %ColorOff% 
IF NOT DEFINED PLAYLIST_URL (
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Nothing to fetch.!padding:~1,-23!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :select-download-list
))
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  EXPORTING...!padding:~1,-18!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
"%YTDLP_PATH%" --no-warnings --simulate --flat-playlist --compat-options no-youtube-unavailable-videos --print-to-file webpage_url "%temp_file1%" "%PLAYLIST_URL%"
IF %errorlevel% EQU 0 (
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Done. Download List is set as current Source URL. Press any key.!padding:~1,-70!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
"%TR_PATH%" -d "\n" < "%temp_file1%" > "%DOWNLOAD_LIST_PATH%"
timeout /t 1 >nul
IF EXIST "%temp_file1%" del /f /q "%temp_file1%" >nul 2>&1
SET PLAYLIST_URL=& SET URL=%DOWNLOAD_LIST_PATH%
) ELSE (
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Something went wrong.!padding:~1,-27!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :select-download-list
)
PAUSE >nul
IF DEFINED ContinueHook (GOTO :continue) ELSE (GOTO :select-download-list)

:playlist-error
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  Allowed failures for playlists ^(until the rest of the playlist is skipped^)!padding:~1,-80!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╯%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  1 Error
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  2 Errors
ECHO %Blue-s%│%ColorOff%  %Cyan-s%3%ColorOff%  3 Errors
ECHO %Blue-s%│%ColorOff%  %Cyan-s%4%ColorOff%  4 Errors
ECHO %Blue-s%│%ColorOff%  %Cyan-s%5%ColorOff%  5 Errors
ECHO %Blue-s%│%ColorOff%  %Cyan-s%6%ColorOff%  6 Errors
ECHO %Blue-s%│%ColorOff%  %Cyan-s%7%ColorOff%  7 Errors
ECHO %Blue-s%│%ColorOff%  %Cyan-s%8%ColorOff%  8 Errors
ECHO %Blue-s%┝%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-n%a%ColorOff%  Always Abort On Errors!padding:~1,-28!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%r%ColorOff%  Never Abort On Errors!padding:~1,-27!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Enter your choice: 
IF "%choice%"=="1" SET stop_on_error=1& IF DEFINED ContinueHook (GOTO :continue) ELSE (GOTO :settings)
IF "%choice%"=="2" SET stop_on_error=2& IF DEFINED ContinueHook (GOTO :continue) ELSE (GOTO :settings)
IF "%choice%"=="3" SET stop_on_error=3& IF DEFINED ContinueHook (GOTO :continue) ELSE (GOTO :settings)
IF "%choice%"=="4" SET stop_on_error=4& IF DEFINED ContinueHook (GOTO :continue) ELSE (GOTO :settings)
IF "%choice%"=="5" SET stop_on_error=5& IF DEFINED ContinueHook (GOTO :continue) ELSE (GOTO :settings)
IF "%choice%"=="6" SET stop_on_error=6& IF DEFINED ContinueHook (GOTO :continue) ELSE (GOTO :settings)
IF "%choice%"=="7" SET stop_on_error=7& IF DEFINED ContinueHook (GOTO :continue) ELSE (GOTO :settings)
IF "%choice%"=="8" SET stop_on_error=8& IF DEFINED ContinueHook (GOTO :continue) ELSE (GOTO :settings)
IF "%choice%"=="a" SET stop_on_error=9& IF DEFINED ContinueHook (GOTO :continue) ELSE (GOTO :settings)
IF "%choice%"=="r" SET stop_on_error=& IF DEFINED ContinueHook (GOTO :continue) ELSE (GOTO :settings)
IF "%choice%"=="w" IF DEFINED ContinueHook (GOTO :continue) ELSE (GOTO :settings)
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :playlist-error

:aria
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  ARIA DOWNLOADER!padding:~1,-21!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╯%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Enable
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  %Yellow-n%Disable%ColorOff% %Blue-s%^(default^)%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Use aria2c as external downloader? 
IF "%choice%"=="1" SET USEARIA=1& IF DEFINED ContinueHook (GOTO :continue) ELSE (GOTO :settings)
IF "%choice%"=="2" SET USEARIA=& IF DEFINED ContinueHook (GOTO :continue) ELSE (GOTO :settings)
IF "%choice%"=="w" IF DEFINED ContinueHook (GOTO :continue) ELSE (GOTO :settings)
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :aria

:cookies
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  COOKIES!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╯%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Enable
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  %Yellow-n%Disable%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Use cookies from '%COOKIES_PATH%'? 
IF "%choice%"=="1" SET usecookies=1& IF DEFINED ContinueHook (GOTO :continue) ELSE (GOTO :settings)
IF "%choice%"=="2" SET usecookies=& IF DEFINED ContinueHook (GOTO :continue) ELSE (GOTO :settings)
IF "%choice%"=="w" IF DEFINED ContinueHook (GOTO :continue) ELSE (GOTO :settings)
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :cookies

:plugins
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  PLUGINS!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╯%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  SRT_fix
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  ReplayGain
ECHO %Blue-s%│%ColorOff%  %Cyan-s%3%ColorOff%  CustomChapters
ECHO %Blue-s%│%ColorOff%  %Cyan-s%4%ColorOff%  ReturnYoutubeDislike
ECHO %Blue-s%│%ColorOff%  %Cyan-s%5%ColorOff%  YandexTranslate
ECHO %Blue-s%│%ColorOff%  %Cyan-s%6%ColorOff%  SplitAndTag
ECHO %Blue-s%┝%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Select plugin: 
IF "%choice%"=="1" GOTO :plugin-1
IF "%choice%"=="2" GOTO :plugin-2
IF "%choice%"=="3" GOTO :plugin-3
IF "%choice%"=="4" GOTO :plugin-4
IF "%choice%"=="5" GOTO :plugin-5
IF "%choice%"=="6" GOTO :plugin-6
IF "%choice%"=="w" GOTO :settings
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :plugins

:plugin-1
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  SRT_fixer!padding:~1,-15!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╯%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Enable
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  %Yellow-n%Disable%ColorOff% %Blue-s%^(default^)%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Enable SRT_fixer plugin? 
IF "%choice%"=="1" SET use_pl_srtfixer=1& GOTO :plugins
IF "%choice%"=="2" SET use_pl_srtfixer=& GOTO :plugins
IF "%choice%"=="w" GOTO :plugins
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :plugin-1

:plugin-2
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  ReplayGain!padding:~1,-16!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╯%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Enable
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  %Yellow-n%Disable%ColorOff% %Blue-s%^(default^)%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Enable ReplayGain plugin? 
IF "%choice%"=="1" SET use_pl_replaygain=1& GOTO :plugins
IF "%choice%"=="2" SET use_pl_replaygain=& GOTO :plugins
IF "%choice%"=="w" GOTO :plugins
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :plugin-2

:plugin-3
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  CustomChapters!padding:~1,-20!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╯%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Enable
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  %Yellow-n%Disable%ColorOff% %Blue-s%^(default^)%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Use CustomChapters from '%CHAPTERS_PATH%'? 
IF "%choice%"=="1" SET use_pl_customchapters=1& IF DEFINED ContinueHook (GOTO :continue) ELSE (GOTO :plugins)
IF "%choice%"=="2" SET use_pl_customchapters=& IF DEFINED ContinueHook (GOTO :continue) ELSE (GOTO :plugins)
IF "%choice%"=="w" IF DEFINED ContinueHook (GOTO :continue) ELSE (GOTO :plugins)
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :plugin-3

:plugin-4
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  ReturnYoutubeDislike!padding:~1,-26!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╯%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Enable
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  %Yellow-n%Disable%ColorOff% %Blue-s%^(default^)%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Enable ReturnYoutubeDislike plugin? 
IF "%choice%"=="1" SET use_pl_returnyoutubedislike=1& GOTO :plugins
IF "%choice%"=="2" SET use_pl_returnyoutubedislike=& GOTO :plugins
IF "%choice%"=="w" GOTO :plugins
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :plugin-4

:plugin-5
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  Yandex Translate!padding:~1,-22!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╯%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Enable
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  Enable For Audio Too
ECHO %Blue-s%│%ColorOff%  %Cyan-s%3%ColorOff%  %Yellow-n%Disable%ColorOff% %Blue-s%^(default^)%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Enable Yandex Translate plugin? 
IF "%choice%"=="1" SET use_pl_yandextranslate=1& GOTO :plugins
IF "%choice%"=="2" SET use_pl_yandextranslate=2& GOTO :plugins
IF "%choice%"=="3" SET use_pl_yandextranslate=& GOTO :plugins
IF "%choice%"=="w" GOTO :plugins
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :plugin-5

:plugin-6
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  SplitAndTag!padding:~1,-17!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Enable
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  %Yellow-n%Disable%ColorOff% %Blue-s%^(default^)%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%3%ColorOff%  'Track. Title' %Blue-s%^(default^)%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%4%ColorOff%  'Title'
ECHO %Blue-s%│%ColorOff%  %Cyan-s%5%ColorOff%  'Artist - Title'
ECHO %Blue-s%│%ColorOff%  %Cyan-s%6%ColorOff%  'Track. Artist - Title'
ECHO %Blue-s%│%ColorOff%  %Cyan-s%7%ColorOff%  'Track. Title ^(Album^)'
ECHO %Blue-s%│%ColorOff%  %Cyan-s%8%ColorOff%  'Title ^(Artist^)'
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Enable SplitAndTag plugin? 
IF "%choice%"=="1" SET use_pl_splitandtag=1& GOTO :splitandtag
IF "%choice%"=="2" SET use_pl_splitandtag=& IF DEFINED ContinueHook (GOTO :continue) ELSE (GOTO :plugins)
IF "%choice%"=="3" SET use_pl_splitandtag=1& SET SPLIT_REGEX="%%track\.%%title" & IF DEFINED ContinueHook (GOTO :continue) ELSE (GOTO :plugins)
IF "%choice%"=="4" SET use_pl_splitandtag=1& SET SPLIT_REGEX="%%title" & IF DEFINED ContinueHook (GOTO :continue) ELSE (GOTO :plugins)
IF "%choice%"=="5" SET use_pl_splitandtag=1& SET SPLIT_REGEX="%%artist-%%title" & IF DEFINED ContinueHook (GOTO :continue) ELSE (GOTO :plugins)
IF "%choice%"=="6" SET use_pl_splitandtag=1& SET SPLIT_REGEX="%%track\.%%artist-%%title" & IF DEFINED ContinueHook (GOTO :continue) ELSE (GOTO :plugins)
IF "%choice%"=="7" SET use_pl_splitandtag=1& SET SPLIT_REGEX="%%track\.%%title-\(%%album\)" & IF DEFINED ContinueHook (GOTO :continue) ELSE (GOTO :plugins)
IF "%choice%"=="8" SET use_pl_splitandtag=1& SET SPLIT_REGEX="%%title\(%%artist\)" & IF DEFINED ContinueHook (GOTO :continue) ELSE (GOTO :plugins)
IF "%choice%"=="w" IF DEFINED ContinueHook (GOTO :continue) ELSE (GOTO :plugins)
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :plugin-6

:splitandtag
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  Chapter title parsing REGEX; allowed: %%artist/%%album/%%track/%%title. ^(i.e. %%track\.\s%%title will match '1. song'^)!padding:~1,-118!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
SET /P SPLIT_REGEX=%BS%   %Cyan-n%› %ColorOff% Enter REGEX suitable for chapters found on video's page in description: 
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Done!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 1 >nul
IF DEFINED ContinueHook (GOTO :continue) ELSE (GOTO :plugins)

:info
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  VERSION INFO!padding:~1,-18!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
"%YTDLP_PATH%" -v
ECHO.
IF %APP_ERR% NEQ 0 (
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  %Red-s%ERROR%ColorOff%: yt-dlp ErrorLevel is %Cyan-s%%APP_ERR%%ColorOff%.
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
)
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Press any key!padding:~1,-19!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
PAUSE >nul
GOTO :start

:error-info
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  YT-DLP ERROR INFO!padding:~1,-23!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%0%ColorOff%  No error!padding:~1,-14!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%1%ColorOff%  Invalid url/Missing file!padding:~1,-30!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%2%ColorOff%  No arguments/Invalid parameters!padding:~1,-37!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%3%ColorOff%  File I/O error!padding:~1,-20!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%4%ColorOff%  Network failure!padding:~1,-21!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%5%ColorOff%  SSL verification failure!padding:~1,-30!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%6%ColorOff%  Username/Password failure!padding:~1,-31!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%7%ColorOff%  Protocol errors!padding:~1,-21!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%8%ColorOff%  Server issued an error response!padding:~1,-37!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff% %Red-s%403%ColorOff% Bot protection/Need to set cookies!padding:~1,-40!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Press any key!padding:~1,-19!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
PAUSE >nul
GOTO :start

:update
cls
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  UPDATING...!padding:~1,-17!%Blue-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
"%YTDLP_PATH%" -U
ECHO.
IF %APP_ERR% NEQ 0 (
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  %Red-s%ERROR%ColorOff%: yt-dlp ErrorLevel is %Cyan-s%%APP_ERR%%ColorOff%.
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
)
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Press any key!padding:~1,-19!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
PAUSE >nul
GOTO :start

:continue
cls
SET ContinueHook=
IF DEFINED extended_menu (
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  EXTENDED MENU ^(not working for now^)!padding:~1,-46!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
) ELSE (
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  CONTINUE MENU!padding:~1,-19!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╯%ColorOff%
)
:: meant for download another link with same params
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  New URL ^(same parameters^)
:: meant to retry failed download with same params (in case if link is invalid)
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  Retry ^(same parameters^)
ECHO %Blue-s%│%ColorOff%  %Cyan-s%3%ColorOff%  Send URL To Splitter
IF DEFINED extended_menu (
ECHO %Blue-s%│%ColorOff%  %Cyan-s%4%ColorOff%  Enable Smart Splitter
ECHO %Blue-s%│%ColorOff%  %Cyan-s%5%ColorOff%  Enable Custom Chapters
ECHO %Blue-s%│%ColorOff%  %Cyan-s%6%ColorOff%  Change Split And Tag Search Regex
ECHO %Blue-s%│%ColorOff%  %Cyan-s%7%ColorOff%  Enable Timeout Periods
ECHO %Blue-s%│%ColorOff%  %Cyan-s%8%ColorOff%  Enable Cookies
ECHO %Blue-s%│%ColorOff%  %Cyan-s%9%ColorOff%  Enable Proxy
ECHO %Blue-s%│%ColorOff% %Cyan-s%10%ColorOff%  Define Allowed Failures Number
ECHO %Blue-s%│%ColorOff% %Cyan-s%11%ColorOff%  Export Current Playlist To Download List
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
ECHO %Blue-s%│%ColorOff% %Cyan-s%12%ColorOff%  Retry Audio Splitter ^(re-new parameters^)
ECHO %Blue-s%│%ColorOff% %Cyan-s%13%ColorOff%  Retry Audio Single   ^(re-new parameters^)
ECHO %Blue-s%│%ColorOff% %Cyan-s%14%ColorOff%  Retry Audio Playlist ^(re-new parameters^)
ECHO %Blue-s%│%ColorOff% %Cyan-s%15%ColorOff%  Retry Audio Quick    ^(re-new parameters^)
ECHO %Blue-s%│%ColorOff% %Cyan-s%16%ColorOff%  Retry Video Splitter ^(re-new parameters^)
ECHO %Blue-s%│%ColorOff% %Cyan-s%17%ColorOff%  Retry Video Single   ^(re-new parameters^)
ECHO %Blue-s%│%ColorOff% %Cyan-s%18%ColorOff%  Retry Video Playlist ^(re-new parameters^)
ECHO %Blue-s%│%ColorOff% %Cyan-s%19%ColorOff%  Retry Subtitles      ^(re-new parameters^)
ECHO %Blue-s%│%ColorOff% %Cyan-s%20%ColorOff%  Retry Comments       ^(re-new parameters^)
ECHO %Blue-s%│%ColorOff% %Cyan-s%21%ColorOff%  Retry Stream         ^(re-new parameters^)
ECHO %Blue-s%│%ColorOff% %Cyan-s%22%ColorOff%  Retry Sections       ^(re-new parameters^)
)
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%e%ColorOff%  Main Menu ^(keep URL^)!padding:~1,-26!%Blue-s%│%ColorOff%
:: resets all variables
ECHO %Blue-s%│%ColorOff%  %Yellow-s%r%ColorOff%  Main Menu!padding:~1,-15!%Blue-s%│%ColorOff%
:: this seems useless here, params won't change from within this menu. upd. valid for debug mode.
ECHO %Blue-s%│%ColorOff%  %Yellow-s%x%ColorOff%  Enable Extended Menu!padding:~1,-26!%Blue-s%│%ColorOff%
IF DEFINED extended_menu (
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Enable Aria!padding:~1,-17!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%d%ColorOff%  Enable Debug!padding:~1,-18!%Blue-s%│%ColorOff%
)
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Choose an option: 
IF "%choice%"=="1" GOTO :getURL-continue
IF "%choice%"=="2" (IF "%Downloaded-Audio%"=="1" (
GOTO :doYTDL
) ELSE (IF "%Downloaded-Video%"=="1" (
GOTO :doYTDL
) ELSE (IF "%Downloaded-Manual%"=="1" (
GOTO :download-manual
) ELSE (IF "%Downloaded-Manual-Single%"=="1" (
GOTO :download-manual-single
) ELSE (IF "%Downloaded-Comments%"=="1" (
GOTO :doYTDL
) ELSE (IF "%Downloaded-Subs%"=="1" (
GOTO :doYTDL
) ELSE (IF "%Downloaded-Stream%"=="1" (
GOTO :doYTDL-stream
) ELSE (IF "%Downloaded-Sections%"=="1" (
GOTO :doYTDL
) ELSE (IF "%Downloaded-Quick%"=="1" (
GOTO :doYTDL-quick
) ELSE (
GOTO :continue
))))))))))
IF "%choice%"=="3" SET smart_splitter=1& GOTO :doYTDL-check-smart
IF "%choice%"=="4" SET ContinueHook=1& GOTO :smart-splitter
IF "%choice%"=="5" SET ContinueHook=1& GOTO :plugin-3
IF "%choice%"=="6" SET ContinueHook=1& GOTO :plugin-6
IF "%choice%"=="7" SET ContinueHook=1& GOTO :timeouts
IF "%choice%"=="8" SET ContinueHook=1& GOTO :cookies
IF "%choice%"=="9" SET ContinueHook=1& GOTO :proxy
IF "%choice%"=="10" SET ContinueHook=1& GOTO :playlist-error
IF "%choice%"=="11" SET ContinueHook=1& GOTO :playlist-export
IF "%choice%"=="12" GOTO :doYTDL-audio-preset-1
IF "%choice%"=="13" GOTO :doYTDL-audio-preset-2
IF "%choice%"=="14" GOTO :doYTDL-audio-preset-3
IF "%choice%"=="15" GOTO :doYTDL-preset-quick
IF "%choice%"=="16" GOTO :doYTDL-video-preset-1
IF "%choice%"=="17" GOTO :doYTDL-video-preset-2
IF "%choice%"=="18" GOTO :doYTDL-video-preset-3
IF "%choice%"=="19" GOTO :subs-preset-1
IF "%choice%"=="20" GOTO :comments-preset-1
IF "%choice%"=="21" GOTO :doYTDL-preset-stream-1
IF "%choice%"=="22" GOTO :sections-preset-1
IF "%choice%"=="x" SET extended_menu=1& GOTO :continue
IF "%choice%"=="d" SET enable_debug=1& GOTO :continue
IF "%choice%"=="r" SET URL=& SET Downloaded-Video=& SET Downloaded-Audio=& SET Downloaded-Manual=& SET Downloaded-Manual-Single=& SET Downloaded-Comments=& SET Downloaded-Subs=& SET AudioQuality=& SET DownloadList=& SET VideoResolution=& SET VideoFPS=& SET CustomFormatVideo=& SET StreamAudioFormat=& SET CustomFormat-m4a=& SET CustomFormat-mp3=& SET quality_libfdk=& SET CustomFormat-opus=& SET StreamVideoFormat=& SET CommentPreset=& SET SectionsAudio=& SET SectionsVideo=& SET DoSections=& SET Downloaded-Sections=& SET Downloaded-Stream=& SET OnlyNew=& SET Downloaded-Quick=& SET SubsPreset=& SET FormatTitle=& SET CustomFormat-ogg=& SET CropThumb=& SET VariousArtists=& SET quality_simple=& SET CustomFormatAudio=& SET CustomChapters=& SET ReplayGainPreset=& SET BestAudio=& SET aac-at-param-1=& SET aac-at-param-2=& SET aac-at-param-3=& SET aac-at-param-4=& SET aac-at-param-5=& SET CustomCodec=& SET ContinueHook=& SET ALBUM=& GOTO :start
REM IF "%choice%"=="e" GOTO :getURL-re-enter
REM go to main menu but keep URL
IF "%choice%"=="e" SET Downloaded-Video=& SET Downloaded-Audio=& SET Downloaded-Manual=& SET Downloaded-Manual-Single=& SET Downloaded-Comments=& SET Downloaded-Subs=& SET AudioQuality=& SET DownloadList=& SET VideoResolution=& SET VideoFPS=& SET CustomFormatVideo=& SET StreamAudioFormat=& SET CustomFormat-m4a=& SET CustomFormat-mp3=& SET quality_libfdk=& SET CustomFormat-opus=& SET StreamVideoFormat=& SET CommentPreset=& SET SectionsAudio=& SET SectionsVideo=& SET DoSections=& SET Downloaded-Sections=& SET Downloaded-Stream=& SET OnlyNew=& SET Downloaded-Quick=& SET SubsPreset=& SET FormatTitle=& SET CustomFormat-ogg=& SET CropThumb=& SET VariousArtists=& SET quality_simple=& SET CustomFormatAudio=& SET CustomChapters=& SET ReplayGainPreset=& SET BestAudio=& SET aac-at-param-1=& SET aac-at-param-2=& SET aac-at-param-3=& SET aac-at-param-4=& SET aac-at-param-5=& SET CustomCodec=& SET ContinueHook=& SET ALBUM=& GOTO :start
IF "%choice%"=="w" SET ContinueHook=1& GOTO :aria
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :continue

:getURL-continue
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  ENTER SOURCE URL!padding:~1,-22!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /P URL=%BS%   %Cyan-n%› %ColorOff% 
IF NOT DEFINED URL EXIT /B %APP_ERR%
IF "%Downloaded-Audio%"=="1" (
GOTO :doYTDL
) ELSE (IF "%Downloaded-Video%"=="1" (
GOTO :doYTDL
) ELSE (IF "%Downloaded-Manual%"=="1" (
GOTO :download-manual
) ELSE (IF "%Downloaded-Manual-Single%"=="1" (
GOTO :download-manual-single
) ELSE (IF "%Downloaded-Comments%"=="1" (
GOTO :doYTDL
) ELSE (IF "%Downloaded-Subs%"=="1" (
GOTO :doYTDL
) ELSE (IF "%Downloaded-Stream%"=="1" (
GOTO :doYTDL-stream
) ELSE (IF "%Downloaded-Sections%"=="1" (
GOTO :select-preset-sections
) ELSE (IF "%Downloaded-Quick%"=="1" (
GOTO :doYTDL-quick
) ELSE (IF "!URL-Hook-Audio!"=="1" (
SET !URL-Hook-Audio!=& GOTO :select-format-audio
) ELSE (IF "!URL-Hook-Video!"=="1" (
SET !URL-Hook-Video!=& GOTO :select-format-video
) ELSE (IF "!URL-Hook-List!"=="1" (
SET !URL-Hook-List!=& GOTO :select-download-list
) ELSE (IF "!URL-Hook-Manual!"=="1" (
SET !URL-Hook-Manual!=& GOTO :select-format-manual
) ELSE (IF "!URL-Hook-Subs!"=="1" (
SET !URL-Hook-Subs!=& GOTO :select-preset-subs
) ELSE (IF "!URL-Hook-Comments!"=="1" (
SET !URL-Hook-Comments!=& GOTO :select-preset-comments
) ELSE (IF "!URL-Hook-Sections!"=="1" (
SET !URL-Hook-Sections!=& GOTO :select-preset-sections
) ELSE (IF "!URL-Hook-Stream!"=="1" (
SET !URL-Hook-Stream!=& GOTO :select-format-stream
) ELSE (
GOTO :start
)))))))))))))))))

:exit
cls
ECHO %Cyan-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Cyan-s%│%ColorOff%  %Cyan-s%•%ColorOff%  See Ya, Space Cowboy...!padding:~1,-29!%Cyan-s%│%ColorOff%
ECHO %Cyan-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
EXIT /B 0

::
::
:: CUSTOM MENU PART
::
::

:select-format-manual
cls
SET Downloaded-Manual=& SET Downloaded-Manual-Single=
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  FETCHING URL...!padding:~1,-21!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
"%YTDLP_PATH%" --list-formats --no-playlist --simulate --ffmpeg-location "%FFMPEG_PATH%" --js-runtimes "%JS_RUNTIME_NAME%:%JS_RUNTIME_PATH%" --extractor-args "youtube:%EXTRACTOR_ARGS%" "%URL%"
IF NOT DEFINED reasonable-timeouts (IF DEFINED USEARIA (
SET     Download= -i --ignore-config --js-runtimes "%JS_RUNTIME_NAME%:%JS_RUNTIME_PATH%" --downloader "%ARIA2_PATH%" --downloader-args "aria2c: %ARIA_ARGS%" --compat-options no-external-downloader-progress --ffmpeg-location "%FFMPEG_PATH%" --output "%TARGET_FOLDER%\%%(title)s.%%(ext)s"
) ELSE (
SET     Download= -i --ignore-config --js-runtimes "%JS_RUNTIME_NAME%:%JS_RUNTIME_PATH%" --limit-rate %SPEED_LIMIT% --retries %RETRIES% --fragment-retries %FRAGMENT_RETRIES% --buffer-size %BUFFER_SIZE% --concurrent-fragments %THREADS% --ffmpeg-location "%FFMPEG_PATH%" --output "%TARGET_FOLDER%\%%(title)s.%%(ext)s"
)) ELSE (IF DEFINED USEARIA (
SET     Download= -i --ignore-config --js-runtimes "%JS_RUNTIME_NAME%:%JS_RUNTIME_PATH%" %SLEEP% --downloader "%ARIA2_PATH%" --downloader-args "aria2c: %ARIA_ARGS%" --compat-options no-external-downloader-progress --ffmpeg-location "%FFMPEG_PATH%" --output "%TARGET_FOLDER%\%%(title)s.%%(ext)s"
) ELSE (
SET     Download= -i --ignore-config --js-runtimes "%JS_RUNTIME_NAME%:%JS_RUNTIME_PATH%" %SLEEP% --limit-rate %SPEED_LIMIT% --retries %RETRIES% --fragment-retries %FRAGMENT_RETRIES% --buffer-size %BUFFER_SIZE% --concurrent-fragments %THREADS% --ffmpeg-location "%FFMPEG_PATH%" --output "%TARGET_FOLDER%\%%(title)s.%%(ext)s"
))
GOTO :selection

:selection
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Video + Audio		%Yellow-s%w%ColorOff%  Go Back!padding:~1,-42!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  Audio Only / Video Only	%Red-s%q%ColorOff%  Exit!padding:~1,-39!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /P choice=%BS%   %Cyan-n%› %ColorOff% Select Option: 
IF "%choice%"=="1" GOTO :selection-manual
IF "%choice%"=="2" GOTO :selection-manual-single
IF "%choice%"=="w" GOTO :start
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :selection

:selection-manual
SET /P video=%BS%   %Cyan-n%› %ColorOff% Select Video Format: 
SET /P audio=%BS%   %Cyan-n%› %ColorOff% Select Audio Format: 
GOTO :download-manual

:download-manual
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  DOWNLOADING...!padding:~1,-20!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
"%YTDLP_PATH%" -f "%video%+%audio%" %Download% "%URL%"
IF %APP_ERR% NEQ 0 (
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  %Red-s%ERROR%ColorOff%: yt-dlp ErrorLevel is %Cyan-s%%APP_ERR%%ColorOff%.
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
) ELSE (IF "%APP_ERR%"=="1" (
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Re-enter correct format.!padding:~1,-30!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :selection-manual
))
SET Downloaded-Video=& SET Downloaded-Audio=& SET Downloaded-Manual=1& SET Downloaded-Manual-Single=& SET Downloaded-Comments=& SET Downloaded-Subs=& SET Downloaded-Stream=& SET Downloaded-Sections=& SET Downloaded-Quick=
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Press any key!padding:~1,-19!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
PAUSE >nul
GOTO :continue

:selection-manual-single
SET /P format=%BS%   %Cyan-n%› %ColorOff% Select Format: 
GOTO :download-manual-single

:download-manual-single
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  DOWNLOADING...!padding:~1,-20!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
"%YTDLP_PATH%" -f "%format%" %Download% "%URL%"
IF %APP_ERR% NEQ 0 (
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  %Red-s%ERROR%ColorOff%: yt-dlp ErrorLevel is %Cyan-s%%APP_ERR%%ColorOff%.
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
) ELSE (IF "%APP_ERR%"=="1" (
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Re-enter correct format.!padding:~1,-30!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :selection-manual-single
))
SET Downloaded-Video=& SET Downloaded-Audio=& SET Downloaded-Manual=& SET Downloaded-Manual-Single=1& SET Downloaded-Comments=& SET Downloaded-Subs=& SET Downloaded-Stream=& SET Downloaded-Sections=& SET Downloaded-Quick=
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Press any key!padding:~1,-19!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
PAUSE >nul
GOTO :continue

::
::
:: AUDIO MENU PART
::
::

:select-format-audio
SET CustomFormat-m4a=& SET CustomFormat-mp3=& SET CustomFormat-opus=& SET CustomFormat-ogg=& SET CustomFormatAudio=& SET BestAudio=
SET Downloaded-Audio=
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  AUDIO FORMAT!padding:~1,-18!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Extract Best	%Cyan-s%11%ColorOff%  Extract opus ^(from dash^)
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  Extract opus 	%Cyan-s%12%ColorOff%  Extract opus ^(up to 4.0^)
ECHO %Blue-s%│%ColorOff%  %Cyan-s%3%ColorOff%  Extract mp4a	%Cyan-s%13%ColorOff%  Extract opus ^(up to 4.0^) + ^(downmix to 2.0/%AUDIO_BITRATE%k/filter^)
ECHO %Blue-s%│%ColorOff%  %Cyan-s%4%ColorOff%  Extract vorbis	%Cyan-s%14%ColorOff%  Extract mp4a ^(up to 5.1^)
"%FFMPEG_PATH%" -encoders -hide_banner | "%GREP_PATH%" -wq "libfdk_aac" >nul 2>&1
if %errorlevel% equ 0 (
ECHO %Blue-s%│%ColorOff%  %Cyan-s%5%ColorOff%  Extract mp3      	%Cyan-s%15%ColorOff%  Extract mp4a ^(up to 5.1^) + ^(downmix to 2.0/VBR/filter^)
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%6%ColorOff%  Convert → m4a	%Cyan-s%16%ColorOff%  Convert → m4a ^(fraunhofer_aac/VBR^)
ECHO %Blue-s%│%ColorOff%  %Cyan-s%7%ColorOff%  Convert → mp3	%Cyan-s%17%ColorOff%  Convert → m4a ^(fraunhofer_aac/VBR/filter^)
) ELSE (
ECHO %Blue-s%│%ColorOff%  %Cyan-s%5%ColorOff%  Extract mp3
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%6%ColorOff%  Convert → m4a
ECHO %Blue-s%│%ColorOff%  %Cyan-s%7%ColorOff%  Convert → mp3
)
"%FFMPEG_PATH%" -encoders -hide_banner | "%GREP_PATH%" -wq "aac_at" >nul 2>&1
if %errorlevel% equ 0 (
ECHO %Blue-s%│%ColorOff%  %Cyan-s%8%ColorOff%  Convert → opus	%Cyan-s%18%ColorOff%  Convert → m4a ^(apple_aac^)
ECHO %Blue-s%│%ColorOff%  %Cyan-s%9%ColorOff%  Convert → aac	%Cyan-s%19%ColorOff%  Convert → m4a ^(apple_aac/filter^)
ECHO %Blue-s%│%ColorOff% %Cyan-s%10%ColorOff%  Convert → ogg	%Cyan-s%20%ColorOff%  Convert → m4a ^(apple_aac^) + ^(downmix to 2.0/filter^)
) ELSE (
ECHO %Blue-s%│%ColorOff%  %Cyan-s%8%ColorOff%  Convert → opus
ECHO %Blue-s%│%ColorOff%  %Cyan-s%9%ColorOff%  Convert → aac
ECHO %Blue-s%│%ColorOff% %Cyan-s%10%ColorOff%  Convert → ogg
)
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Select audio format: 
IF "%choice%"=="1" SET CustomFormatAudio=1& SET BestAudio=1& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="2" SET CustomFormatAudio=1& SET CustomFormat-opus=1& SET AudioFormat=opus& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="3" SET CustomFormatAudio=1& SET CustomFormat-m4a=1& SET AudioFormat=m4a& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="4" SET CustomFormatAudio=1& SET CustomFormat-ogg=1& SET AudioFormat=vorbis& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="5" SET CustomFormatAudio=1& SET CustomFormat-mp3=1& SET AudioFormat=mp3& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="6" SET AudioFormat=m4a& GOTO :select-quality-audio
IF "%choice%"=="7" SET AudioFormat=mp3& GOTO :select-quality-audio
IF "%choice%"=="8" SET AudioFormat=opus& GOTO :select-quality-audio
IF "%choice%"=="9" SET AudioFormat=aac& GOTO :select-quality-audio
IF "%choice%"=="10" SET AudioFormat=vorbis& GOTO :select-quality-audio
IF "%choice%"=="11" SET CustomFormatAudio=1& SET CustomFormat-opus=4& SET AudioFormat=opus& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="12" SET CustomFormatAudio=1& SET CustomFormat-opus=2& SET AudioFormat=opus& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="13" SET CustomFormatAudio=1& SET CustomFormat-opus=3& SET AudioFormat=opus& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="14" SET CustomFormatAudio=1& SET CustomFormat-m4a=3& SET AudioFormat=m4a& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="15" SET CustomFormat-m4a=5& SET AudioFormat=m4a& GOTO :select-quality-vbr-audio
IF "%choice%"=="16" SET CustomFormat-m4a=2& SET AudioFormat=m4a& GOTO :select-quality-vbr-audio
IF "%choice%"=="17" SET CustomFormat-m4a=4& SET AudioFormat=m4a& GOTO :select-quality-vbr-audio
IF "%choice%"=="18" SET CustomFormat-m4a=6& SET AudioFormat=m4a& GOTO :select-quality-vbr-at-audio
IF "%choice%"=="19" SET CustomFormat-m4a=7& SET AudioFormat=m4a& GOTO :select-quality-vbr-at-audio
IF "%choice%"=="20" SET CustomFormat-m4a=8& SET AudioFormat=m4a& GOTO :select-quality-vbr-at-audio
IF "%choice%"=="w" IF "%SectionsAudio%"=="1" (GOTO :select-preset-sections) ELSE (IF "%SectionsAudio%"=="2" (GOTO :select-preset-sections) ELSE (IF "%DownloadList%"=="1" (GOTO :select-download-list) ELSE (IF "%DownloadList%"=="2" (GOTO :select-download-list) ELSE (GOTO :start))))
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :select-format-audio

:select-quality-audio
SET quality_libfdk=& SET quality_simple=& SET quality_aac_at=
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  AUDIO QUALITY!padding:~1,-19!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
IF "%AudioFormat%"=="mp3" (
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Quality 0 ^(~220-260 Kbps/VBR^)
) ELSE (
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Quality 1
)
IF "%AudioFormat%"=="mp3" (
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  Quality 2 ^(~170-210 Kbps/VBR^)
) ELSE (
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  Quality 2
)
IF "%AudioFormat%"=="mp3" (
ECHO %Blue-s%│%ColorOff%  %Cyan-s%3%ColorOff%  Quality 3 ^(~150-195 Kbps/VBR^)
) ELSE (
ECHO %Blue-s%│%ColorOff%  %Cyan-s%3%ColorOff%  Quality 3
)
IF "%AudioFormat%"=="mp3" (
ECHO %Blue-s%│%ColorOff%  %Cyan-s%4%ColorOff%  Quality 4 ^(~140-185 Kbps/VBR^)
) ELSE (
ECHO %Blue-s%│%ColorOff%  %Cyan-s%4%ColorOff%  Quality 4
)
IF "%AudioFormat%"=="mp3" (
ECHO %Blue-s%│%ColorOff%  %Cyan-s%5%ColorOff%  Quality 5 ^(~120-150 Kbps/VBR^) %Blue-s%^(default^)%ColorOff% 
) ELSE (
ECHO %Blue-s%│%ColorOff%  %Cyan-s%5%ColorOff%  Quality 5 %Blue-s%^(default^)%ColorOff%
)
IF "%AudioFormat%"=="mp3" (
ECHO %Blue-s%│%ColorOff%  %Cyan-s%6%ColorOff%  Quality 6 ^(~100-130 Kbps/VBR^)
) ELSE (
ECHO %Blue-s%│%ColorOff%  %Cyan-s%6%ColorOff%  Quality 6
)
IF "%AudioFormat%"=="mp3" (
ECHO %Blue-s%│%ColorOff%  %Cyan-s%7%ColorOff%  Quality 7 ^(~80-120 Kbps/VBR^)
) ELSE (IF "%AudioFormat%"=="m4a" (
ECHO %Blue-s%│%ColorOff%  %Cyan-s%7%ColorOff%  Quality 7 ^(~204-216 Kbps^) ^(optimal^) 
) ELSE (
ECHO %Blue-s%│%ColorOff%  %Cyan-s%7%ColorOff%  Quality 7
))
IF "%AudioFormat%"=="mp3" (
ECHO %Blue-s%│%ColorOff%  %Cyan-s%8%ColorOff%  Quality 8 ^(~70-105 Kbps/VBR^)
) ELSE (
ECHO %Blue-s%│%ColorOff%  %Cyan-s%8%ColorOff%  Quality 8
)
IF "%AudioFormat%"=="mp3" (
ECHO %Blue-s%│%ColorOff%  %Cyan-s%9%ColorOff%  Quality 9 ^(~45-85 Kbps/VBR^)
) ELSE (
ECHO %Blue-s%│%ColorOff%  %Cyan-s%9%ColorOff%  Quality 9
)
ECHO %Blue-s%│%ColorOff% %Cyan-s%10%ColorOff%  Quality 10 ^(worst, smaller^)
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
IF "%AudioFormat%"=="mp3" (
ECHO %Blue-s%│%ColorOff% %Cyan-s%11%ColorOff%  Quality 320k ^(320 Kbps/CBR^)
) ELSE (
ECHO %Blue-s%│%ColorOff% %Cyan-s%11%ColorOff%  Quality 0 ^(best, overkill^)
)
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%r%ColorOff%  Main Menu!padding:~1,-15!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Select audio quality: 
IF "%choice%"=="1" SET quality_simple=1& SET AudioQuality=1& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="2" SET quality_simple=1& SET AudioQuality=2& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="3" SET quality_simple=1& SET AudioQuality=3& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="4" SET quality_simple=1& SET AudioQuality=4& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="5" SET quality_simple=1& SET AudioQuality=5& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="6" SET quality_simple=1& SET AudioQuality=6& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="7" SET quality_simple=1& SET AudioQuality=7& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="8" SET quality_simple=1& SET AudioQuality=8& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="9" SET quality_simple=1& SET AudioQuality=9& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="10" SET quality_simple=1& SET AudioQuality=10& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="11" IF "%AudioFormat%"=="mp3" (SET quality_simple=1& SET AudioQuality=320k& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))) ELSE (SET quality_simple=1& SET AudioQuality=0& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio)))))
IF "%choice%"=="w" GOTO :select-format-audio
IF "%choice%"=="r" SET Downloaded-Video=& SET Downloaded-Audio=& SET Downloaded-Manual=& SET Downloaded-Manual-Single=& SET Downloaded-Comments=& SET Downloaded-Subs=& SET AudioQuality=& SET DownloadList=& SET VideoResolution=& SET VideoFPS=& SET CustomFormatVideo=& SET StreamAudioFormat=& SET CustomFormat-m4a=& SET CustomFormat-mp3=& SET quality_libfdk=& SET CustomFormat-opus=& SET StreamVideoFormat=& SET CommentPreset=& SET SectionsAudio=& SET SectionsVideo=& SET DoSections=& SET Downloaded-Sections=& SET Downloaded-Stream=& SET OnlyNew=& SET Downloaded-Quick=& SET SubsPreset=& SET FormatTitle=& SET CustomFormat-ogg=& SET CropThumb=& SET VariousArtists=& SET quality_simple=& SET CustomFormatAudio=& SET CustomChapters=& SET ReplayGainPreset=& SET BestAudio=& SET aac-at-param-1=& SET aac-at-param-2=& SET aac-at-param-3=& SET aac-at-param-4=& SET aac-at-param-5=& SET CustomCodec=& SET ContinueHook=& SET ALBUM=& GOTO :start
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :select-quality-audio

:select-quality-vbr-audio
SET quality_libfdk=& SET quality_simple=& SET quality_aac_at=
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  FRAUNHOFER AAC ENCODER QUALITY!padding:~1,-36!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Quality 1 ^(~40-62 Kbps) ^(worst^)
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  Quality 2 ^(~64-80 Kbps^)
ECHO %Blue-s%│%ColorOff%  %Cyan-s%3%ColorOff%  Quality 3 ^(~96-112 Kbps^)
ECHO %Blue-s%│%ColorOff%  %Cyan-s%4%ColorOff%  Quality 4 ^(~128-144 Kbps^)
ECHO %Blue-s%│%ColorOff%  %Cyan-s%5%ColorOff%  Quality 5 ^(~192-224 Kbps^) ^(best^)
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%6%ColorOff%  Quality 0 ^(disables VBR, enables CBR^)
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%r%ColorOff%  Main Menu!padding:~1,-15!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Select audio quality: 
IF "%choice%"=="1" SET quality_libfdk=1& SET AudioQuality=1& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="2" SET quality_libfdk=1& SET AudioQuality=2& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="3" SET quality_libfdk=1& SET AudioQuality=3& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="4" SET quality_libfdk=1& SET AudioQuality=4& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="5" SET quality_libfdk=1& SET AudioQuality=5& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="6" SET quality_libfdk=1& SET AudioQuality=0& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="w" GOTO :select-format-audio
IF "%choice%"=="r" SET Downloaded-Video=& SET Downloaded-Audio=& SET Downloaded-Manual=& SET Downloaded-Manual-Single=& SET Downloaded-Comments=& SET Downloaded-Subs=& SET AudioQuality=& SET DownloadList=& SET VideoResolution=& SET VideoFPS=& SET CustomFormatVideo=& SET StreamAudioFormat=& SET CustomFormat-m4a=& SET CustomFormat-mp3=& SET quality_libfdk=& SET CustomFormat-opus=& SET StreamVideoFormat=& SET CommentPreset=& SET SectionsAudio=& SET SectionsVideo=& SET DoSections=& SET Downloaded-Sections=& SET Downloaded-Stream=& SET OnlyNew=& SET Downloaded-Quick=& SET SubsPreset=& SET FormatTitle=& SET CustomFormat-ogg=& SET CropThumb=& SET VariousArtists=& SET quality_simple=& SET CustomFormatAudio=& SET CustomChapters=& SET ReplayGainPreset=& SET BestAudio=& SET aac-at-param-1=& SET aac-at-param-2=& SET aac-at-param-3=& SET aac-at-param-4=& SET aac-at-param-5=& SET CustomCodec=& SET ContinueHook=& SET ALBUM=& GOTO :start
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :select-quality-vbr-audio

:select-quality-vbr-at-audio
SET quality_libfdk=& SET quality_simple=& SET quality_aac_at=
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  APPLE AAC ENCODER QUALITY!padding:~1,-31!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╯%ColorOff%
ECHO %Blue-s%│%ColorOff%  ╭―――――――――――――――――――――――╮    ╭―――――――――――――――――――――╮    ╭―――――――――――――――――――――╮
ECHO %Blue-s%│%ColorOff%  ^│          VBR          ^│    ^│        CVBR         ^│    ^│         ABR         ^│
ECHO %Blue-s%│%ColorOff%  ╰―――――――――――――――――――――――╯    ╰―――――――――――――――――――――╯    ╰―――――――――――――――――――――╯
ECHO %Blue-s%│%ColorOff%  %Cyan-s%01%ColorOff%  Quality 0 ^(~320 Kbps^)    %Cyan-s%16%ColorOff%  Quality 256k ^(CVBR^)    %Cyan-s%28%ColorOff%  Quality 256k  ^(ABR^)
ECHO %Blue-s%│%ColorOff%  %Cyan-s%02%ColorOff%  Quality 1                %Cyan-s%17%ColorOff%  Quality 224k ^(CVBR^)    %Cyan-s%29%ColorOff%  Quality 224k  ^(ABR^)
ECHO %Blue-s%│%ColorOff%  %Cyan-s%03%ColorOff%  Quality 2 ^(~256 Kbps^)    %Cyan-s%18%ColorOff%  Quality 202k ^(CVBR^)    %Cyan-s%30%ColorOff%  Quality 202k  ^(ABR^)
ECHO %Blue-s%│%ColorOff%  %Cyan-s%04%ColorOff%  Quality 3 ^(~214 Kbps^)    %Cyan-s%19%ColorOff%  Quality 182k ^(CVBR^)    %Cyan-s%31%ColorOff%  Quality 182k  ^(ABR^)
ECHO %Blue-s%│%ColorOff%  %Cyan-s%05%ColorOff%  Quality 4 ^(~192 Kbps^)    %Cyan-s%20%ColorOff%  Quality 148k ^(CVBR^)    %Cyan-s%32%ColorOff%  Quality 148k  ^(ABR^)
ECHO %Blue-s%│%ColorOff%  %Cyan-s%06%ColorOff%  Quality 5 ^(~160 Kbps^)    %Cyan-s%21%ColorOff%  Quality 128k ^(CVBR^)    %Cyan-s%33%ColorOff%  Quality 128k  ^(ABR^)
ECHO %Blue-s%│%ColorOff%  %Cyan-s%07%ColorOff%  Quality 6 ^(~144 Kbps^)    ╭―――――――――――――――――――――╮    ╭―――――――――――――――――――――╮
ECHO %Blue-s%│%ColorOff%  %Cyan-s%08%ColorOff%  Quality 7 ^(~128 Kbps^)    ^│         CBR         ^│    ^│        HE-AAC       ^│
ECHO %Blue-s%│%ColorOff%  %Cyan-s%09%ColorOff%  Quality 8                ╰―――――――――――――――――――――╯    ╰―――――――――――――――――――――╯  
ECHO %Blue-s%│%ColorOff%  %Cyan-s%10%ColorOff%  Quality 9 ^(~96 Kbps^)     %Cyan-s%22%ColorOff%  Quality 256k  ^(CBR^)    %Cyan-s%34%ColorOff%  High Efficiency AAC
ECHO %Blue-s%│%ColorOff%  %Cyan-s%11%ColorOff%  Quality 10               %Cyan-s%23%ColorOff%  Quality 224k  ^(CBR^)    ╭―――――――――――――――――――――╮
ECHO %Blue-s%│%ColorOff%  %Cyan-s%12%ColorOff%  Quality 11               %Cyan-s%24%ColorOff%  Quality 202k  ^(CBR^)    ^│      HE-AAC_v2      ^│
ECHO %Blue-s%│%ColorOff%  %Cyan-s%13%ColorOff%  Quality 12               %Cyan-s%25%ColorOff%  Quality 182k  ^(CBR^)    ╰―――――――――――――――――――――╯  
ECHO %Blue-s%│%ColorOff%  %Cyan-s%14%ColorOff%  Quality 13               %Cyan-s%26%ColorOff%  Quality 148k  ^(CBR^)    %Cyan-s%35%ColorOff%  High Efficiency AAC
ECHO %Blue-s%│%ColorOff%  %Cyan-s%15%ColorOff%  Quality 14 ^(worst^)       %Cyan-s%27%ColorOff%  Quality 128k  ^(CBR^)
ECHO %Blue-s%┝%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%r%ColorOff%  Main Menu!padding:~1,-15!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Select audio quality: 
IF "%choice%"=="1" SET quality_aac_at=1& SET aac-at-param-1=-aac_at_quality 0& SET aac-at-param-2=-q:a& SET aac-at-param-3=0& SET aac-at-param-4=-aac_at_mode& SET aac-at-param-5=vbr& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="2" SET quality_aac_at=1& SET aac-at-param-1=-aac_at_quality 0& SET aac-at-param-2=-q:a& SET aac-at-param-3=1& SET aac-at-param-4=-aac_at_mode& SET aac-at-param-5=vbr& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="3" SET quality_aac_at=1& SET aac-at-param-1=-aac_at_quality 0& SET aac-at-param-2=-q:a& SET aac-at-param-3=2& SET aac-at-param-4=-aac_at_mode& SET aac-at-param-5=vbr& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="4" SET quality_aac_at=1& SET aac-at-param-1=-aac_at_quality 0& SET aac-at-param-2=-q:a& SET aac-at-param-3=3& SET aac-at-param-4=-aac_at_mode& SET aac-at-param-5=vbr& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="5" SET quality_aac_at=1& SET aac-at-param-1=-aac_at_quality 0& SET aac-at-param-2=-q:a& SET aac-at-param-3=4& SET aac-at-param-4=-aac_at_mode& SET aac-at-param-5=vbr& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="6" SET quality_aac_at=1& SET aac-at-param-1=-aac_at_quality 0& SET aac-at-param-2=-q:a& SET aac-at-param-3=5& SET aac-at-param-4=-aac_at_mode& SET aac-at-param-5=vbr& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="7" SET quality_aac_at=1& SET aac-at-param-1=-aac_at_quality 0& SET aac-at-param-2=-q:a& SET aac-at-param-3=6& SET aac-at-param-4=-aac_at_mode& SET aac-at-param-5=vbr& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="8" SET quality_aac_at=1& SET aac-at-param-1=-aac_at_quality 0& SET aac-at-param-2=-q:a& SET aac-at-param-3=7& SET aac-at-param-4=-aac_at_mode& SET aac-at-param-5=vbr& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="9" SET quality_aac_at=1& SET aac-at-param-1=-aac_at_quality 0& SET aac-at-param-2=-q:a& SET aac-at-param-3=8& SET aac-at-param-4=-aac_at_mode& SET aac-at-param-5=vbr& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="10" SET quality_aac_at=1& SET aac-at-param-1=-aac_at_quality 0& SET aac-at-param-2=-q:a& SET aac-at-param-3=9& SET aac-at-param-4=-aac_at_mode& SET aac-at-param-5=vbr& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="11" SET quality_aac_at=1& SET aac-at-param-1=-aac_at_quality 0& SET aac-at-param-2=-q:a& SET aac-at-param-3=10& SET aac-at-param-4=-aac_at_mode& SET aac-at-param-5=vbr& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="12" SET quality_aac_at=1& SET aac-at-param-1=-aac_at_quality 0& SET aac-at-param-2=-q:a& SET aac-at-param-3=11& SET aac-at-param-4=-aac_at_mode& SET aac-at-param-5=vbr& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="13" SET quality_aac_at=1& SET aac-at-param-1=-aac_at_quality 0& SET aac-at-param-2=-q:a& SET aac-at-param-3=12& SET aac-at-param-4=-aac_at_mode& SET aac-at-param-5=vbr& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="14" SET quality_aac_at=1& SET aac-at-param-1=-aac_at_quality 0& SET aac-at-param-2=-q:a& SET aac-at-param-3=13& SET aac-at-param-4=-aac_at_mode& SET aac-at-param-5=vbr& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="15" SET quality_aac_at=1& SET aac-at-param-1=-aac_at_quality 0& SET aac-at-param-2=-q:a& SET aac-at-param-3=14& SET aac-at-param-4=-aac_at_mode& SET aac-at-param-5=vbr& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="16" SET quality_aac_at=1& SET aac-at-param-1=-aac_at_quality 0& SET aac-at-param-2=-b:a& SET aac-at-param-3=256k& SET aac-at-param-4=-aac_at_mode& SET aac-at-param-5=cvbr& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="17" SET quality_aac_at=1& SET aac-at-param-1=-aac_at_quality 0& SET aac-at-param-2=-b:a& SET aac-at-param-3=224k& SET aac-at-param-4=-aac_at_mode& SET aac-at-param-5=cvbr& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="18" SET quality_aac_at=1& SET aac-at-param-1=-aac_at_quality 0& SET aac-at-param-2=-b:a& SET aac-at-param-3=202k& SET aac-at-param-4=-aac_at_mode& SET aac-at-param-5=cvbr& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="19" SET quality_aac_at=1& SET aac-at-param-1=-aac_at_quality 0& SET aac-at-param-2=-b:a& SET aac-at-param-3=182k& SET aac-at-param-4=-aac_at_mode& SET aac-at-param-5=cvbr& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="20" SET quality_aac_at=1& SET aac-at-param-1=-aac_at_quality 0& SET aac-at-param-2=-b:a& SET aac-at-param-3=148k& SET aac-at-param-4=-aac_at_mode& SET aac-at-param-5=cvbr& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="21" SET quality_aac_at=1& SET aac-at-param-1=-aac_at_quality 0& SET aac-at-param-2=-b:a& SET aac-at-param-3=128k& SET aac-at-param-4=-aac_at_mode& SET aac-at-param-5=cvbr& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="22" SET quality_aac_at=1& SET aac-at-param-1=-aac_at_quality 0& SET aac-at-param-2=-b:a& SET aac-at-param-3=256k& SET aac-at-param-4=-aac_at_mode& SET aac-at-param-5=cbr& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="23" SET quality_aac_at=1& SET aac-at-param-1=-aac_at_quality 0& SET aac-at-param-2=-b:a& SET aac-at-param-3=224k& SET aac-at-param-4=-aac_at_mode& SET aac-at-param-5=cbr& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="24" SET quality_aac_at=1& SET aac-at-param-1=-aac_at_quality 0& SET aac-at-param-2=-b:a& SET aac-at-param-3=202k& SET aac-at-param-4=-aac_at_mode& SET aac-at-param-5=cbr& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="25" SET quality_aac_at=1& SET aac-at-param-1=-aac_at_quality 0& SET aac-at-param-2=-b:a& SET aac-at-param-3=182k& SET aac-at-param-4=-aac_at_mode& SET aac-at-param-5=cbr& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="26" SET quality_aac_at=1& SET aac-at-param-1=-aac_at_quality 0& SET aac-at-param-2=-b:a& SET aac-at-param-3=148k& SET aac-at-param-4=-aac_at_mode& SET aac-at-param-5=cbr& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="27" SET quality_aac_at=1& SET aac-at-param-1=-aac_at_quality 0& SET aac-at-param-2=-b:a& SET aac-at-param-3=128k& SET aac-at-param-4=-aac_at_mode& SET aac-at-param-5=cbr& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="28" SET quality_aac_at=1& SET aac-at-param-1=-aac_at_quality 0& SET aac-at-param-2=-b:a& SET aac-at-param-3=256k& SET aac-at-param-4=-aac_at_mode& SET aac-at-param-5=abr& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="29" SET quality_aac_at=1& SET aac-at-param-1=-aac_at_quality 0& SET aac-at-param-2=-b:a& SET aac-at-param-3=224k& SET aac-at-param-4=-aac_at_mode& SET aac-at-param-5=abr& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="30" SET quality_aac_at=1& SET aac-at-param-1=-aac_at_quality 0& SET aac-at-param-2=-b:a& SET aac-at-param-3=202k& SET aac-at-param-4=-aac_at_mode& SET aac-at-param-5=abr& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="31" SET quality_aac_at=1& SET aac-at-param-1=-aac_at_quality 0& SET aac-at-param-2=-b:a& SET aac-at-param-3=182k& SET aac-at-param-4=-aac_at_mode& SET aac-at-param-5=abr& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="32" SET quality_aac_at=1& SET aac-at-param-1=-aac_at_quality 0& SET aac-at-param-2=-b:a& SET aac-at-param-3=148k& SET aac-at-param-4=-aac_at_mode& SET aac-at-param-5=abr& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="33" SET quality_aac_at=1& SET aac-at-param-1=-aac_at_quality 0& SET aac-at-param-2=-b:a& SET aac-at-param-3=128k& SET aac-at-param-4=-aac_at_mode& SET aac-at-param-5=abr& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="34" SET quality_aac_at=1& SET aac-at-param-1=-aac_at_quality 0& SET aac-at-param-2=-profile:a& SET aac-at-param-3=4& SET aac-at-param-4=& SET aac-at-param-5=& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="35" SET quality_aac_at=1& SET aac-at-param-1=-aac_at_quality 0& SET aac-at-param-2=-profile:a& SET aac-at-param-3=28& SET aac-at-param-4=& SET aac-at-param-5=& IF "%SectionsAudio%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsAudio%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-audio-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-audio-preset-1) ELSE (GOTO :select-preset-audio))))
IF "%choice%"=="w" GOTO :select-format-audio
IF "%choice%"=="r" SET Downloaded-Video=& SET Downloaded-Audio=& SET Downloaded-Manual=& SET Downloaded-Manual-Single=& SET Downloaded-Comments=& SET Downloaded-Subs=& SET AudioQuality=& SET DownloadList=& SET VideoResolution=& SET VideoFPS=& SET CustomFormatVideo=& SET StreamAudioFormat=& SET CustomFormat-m4a=& SET CustomFormat-mp3=& SET quality_libfdk=& SET CustomFormat-opus=& SET StreamVideoFormat=& SET CommentPreset=& SET SectionsAudio=& SET SectionsVideo=& SET DoSections=& SET Downloaded-Sections=& SET Downloaded-Stream=& SET OnlyNew=& SET Downloaded-Quick=& SET SubsPreset=& SET FormatTitle=& SET CustomFormat-ogg=& SET CropThumb=& SET VariousArtists=& SET quality_simple=& SET CustomFormatAudio=& SET CustomChapters=& SET ReplayGainPreset=& SET BestAudio=& SET aac-at-param-1=& SET aac-at-param-2=& SET aac-at-param-3=& SET aac-at-param-4=& SET aac-at-param-5=& SET CustomCodec=& SET ContinueHook=& SET ALBUM=& GOTO :start
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :select-quality-vbr-at-audio

:select-preset-audio
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  AUDIO PRESETS!padding:~1,-19!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Audio Single / Channel				%Cyan-s%12%ColorOff%  Audio Single + Only New
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  Audio Single + Crop Thumbnail			%Cyan-s%13%ColorOff%  Audio Single + Crop Thumbnail + Only New
ECHO %Blue-s%│%ColorOff%  %Cyan-s%3%ColorOff%  Audio Single + Title as "Artist - Title"		%Cyan-s%14%ColorOff%  Audio Single + Title as "Artist - Title" + Only New
ECHO %Blue-s%│%ColorOff%  %Cyan-s%4%ColorOff%  Audio Single + Crop + Title as "Artist - Title"	%Cyan-s%15%ColorOff%  Audio Single + Crop + Title as "Artist - Title" + Only New
ECHO %Blue-s%│%ColorOff%  %Cyan-s%5%ColorOff%  Audio Single + 10 Top Comments			%Cyan-s%16%ColorOff%  Audio Single + Crop Thumbnail + 10 Top Comments
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%6%ColorOff%  Audio Album / Release				%Cyan-s%17%ColorOff%  Audio Album + Only New
ECHO %Blue-s%│%ColorOff%  %Cyan-s%7%ColorOff%  Audio Album + Crop Thumbnail			%Cyan-s%18%ColorOff%  Audio Album + Crop Thumbnail + Only New
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%8%ColorOff%  Audio Playlist					%Cyan-s%19%ColorOff%  Audio Playlist + Only New
ECHO %Blue-s%│%ColorOff%  %Cyan-s%9%ColorOff%  Audio Playlist + Crop Thumbnail			%Cyan-s%20%ColorOff%  Audio Playlist + Crop Thumbnail + Only New
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
ECHO %Blue-s%│%ColorOff% %Cyan-s%10%ColorOff%  Audio Playlist / Various Artists			%Cyan-s%21%ColorOff%  Audio Playlist / Various Artists + Only New
ECHO %Blue-s%│%ColorOff% %Cyan-s%11%ColorOff%  Audio Playlist / Various Artists + Crop Thumbnail	%Cyan-s%22%ColorOff%  Audio Playlist / Various Artists + Crop + Only New
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%r%ColorOff%  Main Menu!padding:~1,-15!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Choose preset: 
IF "%choice%"=="1" IF "%use_pl_replaygain%"=="1" (SET ReplayGainPreset=1& GOTO :doYTDL-audio-preset-2) ELSE (GOTO :doYTDL-audio-preset-2)
IF "%choice%"=="2" SET CropThumb=1& IF "%use_pl_replaygain%"=="1" (SET ReplayGainPreset=1& GOTO :doYTDL-audio-preset-2) ELSE (GOTO :doYTDL-audio-preset-2)
IF "%choice%"=="3" SET FormatTitle=1& IF "%use_pl_replaygain%"=="1" (SET ReplayGainPreset=1& GOTO :doYTDL-audio-preset-2) ELSE (GOTO :doYTDL-audio-preset-2)
IF "%choice%"=="4" SET CropThumb=1& SET FormatTitle=1& IF "%use_pl_replaygain%"=="1" (SET ReplayGainPreset=1& GOTO :doYTDL-audio-preset-2) ELSE (GOTO :doYTDL-audio-preset-2)
IF "%choice%"=="5" SET CommentPreset=1& IF "%use_pl_replaygain%"=="1" (SET ReplayGainPreset=1& GOTO :doYTDL-audio-preset-2) ELSE (GOTO :doYTDL-audio-preset-2)
IF "%choice%"=="6" SET Album=1& IF "%use_pl_replaygain%"=="1" (SET ReplayGainPreset=2& GOTO :doYTDL-audio-preset-3) ELSE (GOTO :doYTDL-audio-preset-3)
IF "%choice%"=="7" SET Album=1& SET CropThumb=1& IF "%use_pl_replaygain%"=="1" (SET ReplayGainPreset=2& GOTO :doYTDL-audio-preset-3) ELSE (GOTO :doYTDL-audio-preset-3)
IF "%choice%"=="8" IF "%use_pl_replaygain%"=="1" (SET ReplayGainPreset=2& GOTO :doYTDL-audio-preset-3) ELSE (GOTO :doYTDL-audio-preset-3)
IF "%choice%"=="9" SET CropThumb=1& IF "%use_pl_replaygain%"=="1" (SET ReplayGainPreset=2& GOTO :doYTDL-audio-preset-3) ELSE (GOTO :doYTDL-audio-preset-3)
IF "%choice%"=="10" SET VariousArtists=1& IF "%use_pl_replaygain%"=="1" (SET ReplayGainPreset=3& GOTO :doYTDL-audio-preset-3) ELSE (GOTO :doYTDL-audio-preset-3)
IF "%choice%"=="11" SET VariousArtists=1& SET CropThumb=1& IF "%use_pl_replaygain%"=="1" (SET ReplayGainPreset=3& GOTO :doYTDL-audio-preset-3) ELSE (GOTO :doYTDL-audio-preset-3)
IF "%choice%"=="12" SET OnlyNew=1& IF "%use_pl_replaygain%"=="1" (SET ReplayGainPreset=1& GOTO :doYTDL-audio-preset-2) ELSE (GOTO :doYTDL-audio-preset-2)
IF "%choice%"=="13" SET OnlyNew=1& SET CropThumb=1& IF "%use_pl_replaygain%"=="1" (SET ReplayGainPreset=1& GOTO :doYTDL-audio-preset-2) ELSE (GOTO :doYTDL-audio-preset-2)
IF "%choice%"=="14" SET OnlyNew=1& SET FormatTitle=1& IF "%use_pl_replaygain%"=="1" (SET ReplayGainPreset=1& GOTO :doYTDL-audio-preset-2) ELSE (GOTO :doYTDL-audio-preset-2)
IF "%choice%"=="15" SET OnlyNew=1& SET CropThumb=1& SET FormatTitle=1& IF "%use_pl_replaygain%"=="1" (SET ReplayGainPreset=1& GOTO :doYTDL-audio-preset-2) ELSE (GOTO :doYTDL-audio-preset-2)
IF "%choice%"=="16" SET CommentPreset=1& SET CropThumb=1& IF "%use_pl_replaygain%"=="1" (SET ReplayGainPreset=1& GOTO :doYTDL-audio-preset-2) ELSE (GOTO :doYTDL-audio-preset-2)
IF "%choice%"=="17" SET Album=1& SET OnlyNew=1& IF "%use_pl_replaygain%"=="1" (SET ReplayGainPreset=2& GOTO :doYTDL-audio-preset-3) ELSE (GOTO :doYTDL-audio-preset-3)
IF "%choice%"=="18" SET Album=1& SET CropThumb=1& SET OnlyNew=1& IF "%use_pl_replaygain%"=="1" (SET ReplayGainPreset=2& GOTO :doYTDL-audio-preset-3) ELSE (GOTO :doYTDL-audio-preset-3)
IF "%choice%"=="19" SET OnlyNew=1& IF "%use_pl_replaygain%"=="1" (SET ReplayGainPreset=2& GOTO :doYTDL-audio-preset-3) ELSE (GOTO :doYTDL-audio-preset-3)
IF "%choice%"=="20" SET CropThumb=1& SET OnlyNew=1& IF "%use_pl_replaygain%"=="1" (SET ReplayGainPreset=2& GOTO :doYTDL-audio-preset-3) ELSE (GOTO :doYTDL-audio-preset-3)
IF "%choice%"=="21" SET VariousArtists=1& SET OnlyNew=1& IF "%use_pl_replaygain%"=="1" (SET ReplayGainPreset=3& GOTO :doYTDL-audio-preset-3) ELSE (GOTO :doYTDL-audio-preset-3)
IF "%choice%"=="22" SET VariousArtists=1& SET CropThumb=1& SET OnlyNew=1& IF "%use_pl_replaygain%"=="1" (SET ReplayGainPreset=3& GOTO :doYTDL-audio-preset-3) ELSE (GOTO :doYTDL-audio-preset-3)
IF "%choice%"=="w" IF "%CustomFormatAudio%"=="1" (GOTO :select-format-audio) ELSE (IF "%quality_libfdk%"=="1" (GOTO :select-quality-vbr-audio) ELSE (GOTO :select-quality-audio))
IF "%choice%"=="r" SET Downloaded-Video=& SET Downloaded-Audio=& SET Downloaded-Manual=& SET Downloaded-Manual-Single=& SET Downloaded-Comments=& SET Downloaded-Subs=& SET AudioQuality=& SET DownloadList=& SET VideoResolution=& SET VideoFPS=& SET CustomFormatVideo=& SET StreamAudioFormat=& SET CustomFormat-m4a=& SET CustomFormat-mp3=& SET quality_libfdk=& SET CustomFormat-opus=& SET StreamVideoFormat=& SET CommentPreset=& SET SectionsAudio=& SET SectionsVideo=& SET DoSections=& SET Downloaded-Sections=& SET Downloaded-Stream=& SET OnlyNew=& SET Downloaded-Quick=& SET SubsPreset=& SET FormatTitle=& SET CustomFormat-ogg=& SET CropThumb=& SET VariousArtists=& SET quality_simple=& SET CustomFormatAudio=& SET CustomChapters=& SET ReplayGainPreset=& SET BestAudio=& SET aac-at-param-1=& SET aac-at-param-2=& SET aac-at-param-3=& SET aac-at-param-4=& SET aac-at-param-5=& SET CustomCodec=& SET ContinueHook=& SET ALBUM=& GOTO :start
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :select-preset-audio

::
::
:: VIDEO MENU PART
::
::

:select-format-video
SET CustomFormatVideo=& SET Downloaded-Video=& SET VideoResolution=& SET VideoFPS=
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  VIDEO QUALITY!padding:~1,-19!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╯%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Best Video
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  1440p/%Red-s%60%ColorOff%fps
ECHO %Blue-s%│%ColorOff%  %Cyan-s%3%ColorOff%  1440p/30fps
ECHO %Blue-s%│%ColorOff%  %Cyan-s%4%ColorOff%  1280p/%Red-s%60%ColorOff%fps
ECHO %Blue-s%│%ColorOff%  %Cyan-s%5%ColorOff%  1280p/30fps
ECHO %Blue-s%│%ColorOff%  %Cyan-s%6%ColorOff%  1080p/%Red-s%60%ColorOff%fps
ECHO %Blue-s%│%ColorOff%  %Cyan-s%7%ColorOff%  1080p/30fps
ECHO %Blue-s%│%ColorOff%  %Cyan-s%8%ColorOff%  720p/%Red-s%60%ColorOff%fps 
ECHO %Blue-s%│%ColorOff%  %Cyan-s%9%ColorOff%  720p/30fps 
ECHO %Blue-s%│%ColorOff% %Cyan-s%10%ColorOff%  480p/30fps
ECHO %Blue-s%│%ColorOff% %Cyan-s%11%ColorOff%  320p/30fps
ECHO %Blue-s%│%ColorOff% %Cyan-s%12%ColorOff%  Worst Video
ECHO %Blue-s%│%ColorOff% %Cyan-s%13%ColorOff%  Smallest Size
ECHO %Blue-s%┝%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Select video quality: 
IF "%choice%"=="1" SET CustomFormatVideo=1& IF "%SectionsVideo%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsVideo%"=="2" (GOTO :doYTDL-video-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-video-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-video-preset-1) ELSE (GOTO :select-preset-video))))
IF "%choice%"=="2" SET VideoResolution=1440& SET VideoFPS=60& GOTO :select-codec-video
IF "%choice%"=="3" SET VideoResolution=1440& SET VideoFPS=30& GOTO :select-codec-video
IF "%choice%"=="4" SET VideoResolution=1280& SET VideoFPS=60& GOTO :select-codec-video
IF "%choice%"=="5" SET VideoResolution=1280& SET VideoFPS=30& GOTO :select-codec-video
IF "%choice%"=="6" SET VideoResolution=1080& SET VideoFPS=60& GOTO :select-codec-video
IF "%choice%"=="7" SET VideoResolution=1080& SET VideoFPS=30& GOTO :select-codec-video
IF "%choice%"=="8" SET VideoResolution=720& SET VideoFPS=60& GOTO :select-codec-video
IF "%choice%"=="9" SET VideoResolution=720& SET VideoFPS=30& GOTO :select-codec-video
IF "%choice%"=="10" SET VideoResolution=480& SET VideoFPS=30& GOTO :select-codec-video
IF "%choice%"=="11" SET VideoResolution=320& SET VideoFPS=30& GOTO :select-codec-video
IF "%choice%"=="12" SET CustomFormatVideo=2& IF "%SectionsVideo%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsVideo%"=="2" (GOTO :doYTDL-video-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-video-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-video-preset-1) ELSE (GOTO :select-preset-video))))
IF "%choice%"=="13" SET CustomFormatVideo=3& IF "%SectionsVideo%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsVideo%"=="2" (GOTO :doYTDL-video-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-video-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-video-preset-1) ELSE (GOTO :select-preset-video))))
IF "%choice%"=="w"  IF "%SectionsVideo%"=="1" (GOTO :select-preset-sections) ELSE (IF "%SectionsVideo%"=="2" (GOTO :select-preset-sections) ELSE (IF "%DownloadList%"=="1" (GOTO :select-download-list) ELSE (IF "%DownloadList%"=="2" (GOTO :select-download-list) ELSE (GOTO :start))))
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :select-format-video

:select-codec-video
SET CustomCodec=
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  VIDEO CODEC!padding:~1,-17!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╯%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Any
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  AVC
ECHO %Blue-s%│%ColorOff%  %Cyan-s%3%ColorOff%  VP9
ECHO %Blue-s%│%ColorOff%  %Cyan-s%4%ColorOff%  AV1
ECHO %Blue-s%┝%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%r%ColorOff%  Main Menu!padding:~1,-15!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Select a codec: 
IF "%choice%"=="1" SET CustomCodec=any& IF "%SectionsVideo%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsVideo%"=="2" (GOTO :doYTDL-video-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-video-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-video-preset-1) ELSE (GOTO :select-preset-video))))
IF "%choice%"=="2" SET CustomCodec=avc& IF "%SectionsVideo%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsVideo%"=="2" (GOTO :doYTDL-video-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-video-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-video-preset-1) ELSE (GOTO :select-preset-video))))
IF "%choice%"=="3" SET CustomCodec=vp9& IF "%SectionsVideo%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsVideo%"=="2" (GOTO :doYTDL-video-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-video-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-video-preset-1) ELSE (GOTO :select-preset-video))))
IF "%choice%"=="4" SET CustomCodec=av1& IF "%SectionsVideo%"=="1" (GOTO :select-sections-number) ELSE (IF "%SectionsVideo%"=="2" (GOTO :doYTDL-video-preset-1) ELSE (IF "%DownloadList%"=="1" (GOTO :doYTDL-video-preset-2) ELSE (IF "%DownloadList%"=="2" (GOTO :doYTDL-video-preset-1) ELSE (GOTO :select-preset-video))))
IF "%choice%"=="w" GOTO :select-format-video
IF "%choice%"=="r" SET Downloaded-Video=& SET Downloaded-Audio=& SET Downloaded-Manual=& SET Downloaded-Manual-Single=& SET Downloaded-Comments=& SET Downloaded-Subs=& SET AudioQuality=& SET DownloadList=& SET VideoResolution=& SET VideoFPS=& SET CustomFormatVideo=& SET StreamAudioFormat=& SET CustomFormat-m4a=& SET CustomFormat-mp3=& SET quality_libfdk=& SET CustomFormat-opus=& SET StreamVideoFormat=& SET CommentPreset=& SET SectionsAudio=& SET SectionsVideo=& SET DoSections=& SET Downloaded-Sections=& SET Downloaded-Stream=& SET OnlyNew=& SET Downloaded-Quick=& SET SubsPreset=& SET FormatTitle=& SET CustomFormat-ogg=& SET CropThumb=& SET VariousArtists=& SET quality_simple=& SET CustomFormatAudio=& SET CustomChapters=& SET ReplayGainPreset=& SET BestAudio=& SET aac-at-param-1=& SET aac-at-param-2=& SET aac-at-param-3=& SET aac-at-param-4=& SET aac-at-param-5=& SET CustomCodec=& SET ContinueHook=& SET ALBUM=& GOTO :start
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :select-codec-video

:select-preset-video
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  VIDEO PRESETS!padding:~1,-19!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╯%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Video Single / Channel				 %Cyan-s%9%ColorOff%  Video Single + Only New
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  Video Single + Top Comments			%Cyan-s%10%ColorOff%  Video Single + Top Comments + Only New
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%3%ColorOff%  Video Album / Release				%Cyan-s%11%ColorOff%  Video Album + Only New
ECHO %Blue-s%│%ColorOff%  %Cyan-s%4%ColorOff%  Video Album + Top Comments				%Cyan-s%12%ColorOff%  Video Album + Top Comments + Only New
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%5%ColorOff%  Video Playlist					%Cyan-s%13%ColorOff%  Video Playlist + Only New
ECHO %Blue-s%│%ColorOff%  %Cyan-s%6%ColorOff%  Video Playlist + Top Comments			%Cyan-s%14%ColorOff%  Video Playlist + Top Comments + Only New
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%7%ColorOff%  Video Playlist / Various Artists			%Cyan-s%15%ColorOff%  Video Playlist / Various Artists + Only New
ECHO %Blue-s%│%ColorOff%  %Cyan-s%8%ColorOff%  Video Playlist / Various Artists + Top Comments	%Cyan-s%16%ColorOff%  Video Playlist / Various Artists + Top Comments + Only New
ECHO %Blue-s%┝%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%r%ColorOff%  Main Menu!padding:~1,-15!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Choose preset: 
IF "%choice%"=="1" GOTO :doYTDL-video-preset-2
IF "%choice%"=="2" SET CommentPreset=1& GOTO :doYTDL-video-preset-2
IF "%choice%"=="3" SET Album=1& GOTO :doYTDL-video-preset-3
IF "%choice%"=="4" SET Album=1& SET CommentPreset=1& GOTO :doYTDL-video-preset-3
IF "%choice%"=="5" GOTO :doYTDL-video-preset-3
IF "%choice%"=="6" SET CommentPreset=1& GOTO :doYTDL-video-preset-3
IF "%choice%"=="7" SET VariousArtists=1& GOTO :doYTDL-video-preset-3
IF "%choice%"=="8" SET VariousArtists=1& SET CommentPreset=1& GOTO :doYTDL-video-preset-3
IF "%choice%"=="9" SET OnlyNew=1& GOTO :doYTDL-video-preset-2
IF "%choice%"=="10" SET CommentPreset=1& SET OnlyNew=1& GOTO :doYTDL-video-preset-2
IF "%choice%"=="11" SET Album=1& SET OnlyNew=1& GOTO :doYTDL-video-preset-3
IF "%choice%"=="12" SET Album=1& SET CommentPreset=1& SET OnlyNew=1& GOTO :doYTDL-video-preset-3
IF "%choice%"=="13" SET OnlyNew=1& GOTO :doYTDL-video-preset-3
IF "%choice%"=="14" SET CommentPreset=1& SET OnlyNew=1& GOTO :doYTDL-video-preset-3
IF "%choice%"=="15" SET VariousArtists=1& SET OnlyNew=1& GOTO :doYTDL-video-preset-3
IF "%choice%"=="16" SET VariousArtists=1& SET CommentPreset=1& SET OnlyNew=1& GOTO :doYTDL-video-preset-3
IF "%choice%"=="w" GOTO :select-codec-video
IF "%choice%"=="r" SET Downloaded-Video=& SET Downloaded-Audio=& SET Downloaded-Manual=& SET Downloaded-Manual-Single=& SET Downloaded-Comments=& SET Downloaded-Subs=& SET AudioQuality=& SET DownloadList=& SET VideoResolution=& SET VideoFPS=& SET CustomFormatVideo=& SET StreamAudioFormat=& SET CustomFormat-m4a=& SET CustomFormat-mp3=& SET quality_libfdk=& SET CustomFormat-opus=& SET StreamVideoFormat=& SET CommentPreset=& SET SectionsAudio=& SET SectionsVideo=& SET DoSections=& SET Downloaded-Sections=& SET Downloaded-Stream=& SET OnlyNew=& SET Downloaded-Quick=& SET SubsPreset=& SET FormatTitle=& SET CustomFormat-ogg=& SET CropThumb=& SET VariousArtists=& SET quality_simple=& SET CustomFormatAudio=& SET CustomChapters=& SET ReplayGainPreset=& SET BestAudio=& SET aac-at-param-1=& SET aac-at-param-2=& SET aac-at-param-3=& SET aac-at-param-4=& SET aac-at-param-5=& SET CustomCodec=& SET ContinueHook=& SET ALBUM=& GOTO :start
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :select-preset-video

::
::
:: SUBS MENU PART
::
::

:select-preset-subs
cls
SET Downloaded-Subs=
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  SUBTITLES!padding:~1,-15!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╯%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Download Subtitles
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  Download Transcript
IF DEFINED use_pl_srtfixer (
ECHO %Blue-s%│%ColorOff%  %Cyan-s%3%ColorOff%  Download Autosubs + SRT_fix
)
ECHO %Blue-s%┝%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Choose option: 
IF "%choice%"=="1" SET SubsPreset=1& GOTO :subs-preset-1
IF "%choice%"=="2" SET SubsPreset=2& GOTO :subs-preset-1
IF "%choice%"=="3" SET SubsPreset=3& GOTO :subs-preset-1
IF "%choice%"=="w" GOTO :start
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :select-preset-subs

::
::
:: COMMENTS MENU PART
::
::

:select-preset-comments
cls
SET Downloaded-Comments=
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  COMMENTS DOWNLOAD!padding:~1,-23!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╯%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%    25 Comments Sorted By TOP
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%    25 Comments Sorted By TOP And Converted To HTML
ECHO %Blue-s%│%ColorOff%  %Cyan-s%3%ColorOff%   500 Comments Sorted By TOP
ECHO %Blue-s%│%ColorOff%  %Cyan-s%4%ColorOff%   500 Comments Sorted By TOP And Converted To HTML
ECHO %Blue-s%│%ColorOff%  %Cyan-s%5%ColorOff%   ALL Comments Sorted By TOP
ECHO %Blue-s%│%ColorOff%  %Cyan-s%6%ColorOff%   ALL Comments Sorted By TOP And Converted To HTML
ECHO %Blue-s%│%ColorOff%  %Cyan-s%7%ColorOff%    25 Comments Sorted By NEW
ECHO %Blue-s%│%ColorOff%  %Cyan-s%8%ColorOff%    25 Comments Sorted By NEW And Converted To HTML
ECHO %Blue-s%│%ColorOff%  %Cyan-s%9%ColorOff%   500 Comments Sorted By NEW
ECHO %Blue-s%│%ColorOff% %Cyan-s%10%ColorOff%   500 Comments Sorted By NEW And Converted To HTML	%Cyan-s%13%ColorOff%   500 Comments Converted To HTML + Sorted By NEW
ECHO %Blue-s%│%ColorOff% %Cyan-s%11%ColorOff%   ALL Comments Sorted By NEW
ECHO %Blue-s%│%ColorOff% %Cyan-s%12%ColorOff%   ALL Comments Sorted By NEW And Converted To HTML
ECHO %Blue-s%┝%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Choose option: 
IF "%choice%"=="1" SET CommentPreset=1& GOTO :comments-preset-1
IF "%choice%"=="2" SET CommentPreset=2& GOTO :comments-preset-1
IF "%choice%"=="3" SET CommentPreset=3& GOTO :comments-preset-1
IF "%choice%"=="4" SET CommentPreset=4& GOTO :comments-preset-1
IF "%choice%"=="5" SET CommentPreset=5& GOTO :comments-preset-1
IF "%choice%"=="6" SET CommentPreset=6& GOTO :comments-preset-1
IF "%choice%"=="7" SET CommentPreset=7& GOTO :comments-preset-1
IF "%choice%"=="8" SET CommentPreset=8& GOTO :comments-preset-1
IF "%choice%"=="9" SET CommentPreset=9& GOTO :comments-preset-1
IF "%choice%"=="10" SET CommentPreset=10& GOTO :comments-preset-1
IF "%choice%"=="11" SET CommentPreset=11& GOTO :comments-preset-1
IF "%choice%"=="12" SET CommentPreset=12& GOTO :comments-preset-1
IF "%choice%"=="13" SET CommentPreset=13& GOTO :comments-preset-1
IF "%choice%"=="w" GOTO :start
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :select-preset-comments

::
::
:: STREAM MENU PART
::
::

:select-format-stream
cls
SET Downloaded-Stream=
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  STREAM TO PLAYER!padding:~1,-22!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╯%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Stream Audio
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  Stream Video
ECHO %Blue-s%┝%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Choose option: 
IF "%choice%"=="1" GOTO :select-quality-audio-stream
IF "%choice%"=="2" GOTO :select-quality-video-stream
IF "%choice%"=="w" GOTO :start
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :select-format-stream

:select-quality-audio-stream
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  STREAM AUDIO QUALITY!padding:~1,-26!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╯%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Best Audio
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  Best Audio + Best Protocol
ECHO %Blue-s%┝%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%r%ColorOff%  Main Menu!padding:~1,-15!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Enter your choice: 
IF "%choice%"=="1" SET StreamVideoFormat=& SET StreamAudioFormat=1& GOTO :doYTDL-preset-stream-1
IF "%choice%"=="2" SET StreamVideoFormat=& SET StreamAudioFormat=2& GOTO :doYTDL-preset-stream-1
IF "%choice%"=="w" GOTO :select-format-stream
IF "%choice%"=="r" SET Downloaded-Video=& SET Downloaded-Audio=& SET Downloaded-Manual=& SET Downloaded-Manual-Single=& SET Downloaded-Comments=& SET Downloaded-Subs=& SET AudioQuality=& SET DownloadList=& SET VideoResolution=& SET VideoFPS=& SET CustomFormatVideo=& SET StreamAudioFormat=& SET CustomFormat-m4a=& SET CustomFormat-mp3=& SET quality_libfdk=& SET CustomFormat-opus=& SET StreamVideoFormat=& SET CommentPreset=& SET SectionsAudio=& SET SectionsVideo=& SET DoSections=& SET Downloaded-Sections=& SET Downloaded-Stream=& SET OnlyNew=& SET Downloaded-Quick=& SET SubsPreset=& SET FormatTitle=& SET CustomFormat-ogg=& SET CropThumb=& SET VariousArtists=& SET quality_simple=& SET CustomFormatAudio=& SET CustomChapters=& SET ReplayGainPreset=& SET BestAudio=& SET aac-at-param-1=& SET aac-at-param-2=& SET aac-at-param-3=& SET aac-at-param-4=& SET aac-at-param-5=& SET CustomCodec=& SET ContinueHook=& SET ALBUM=& GOTO :start
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :select-quality-audio-stream

:select-quality-video-stream
SET VideoResolution=& SET VideoFPS=& SET StreamVideoFormat=& SET StreamAudioFormat=
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  STREAM VIDEO QUALITY!padding:~1,-26!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Streaming Preset 1
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  Streaming Preset 2
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%3%ColorOff%  Best Video
ECHO %Blue-s%│%ColorOff%  %Cyan-s%4%ColorOff%  1440p/%Red-s%60%ColorOff%fps
ECHO %Blue-s%│%ColorOff%  %Cyan-s%5%ColorOff%  1440p/30fps
ECHO %Blue-s%│%ColorOff%  %Cyan-s%6%ColorOff%  1280p/%Red-s%60%ColorOff%fps
ECHO %Blue-s%│%ColorOff%  %Cyan-s%7%ColorOff%  1280p/30fps
ECHO %Blue-s%│%ColorOff%  %Cyan-s%8%ColorOff%  1080p/%Red-s%60%ColorOff%fps
ECHO %Blue-s%│%ColorOff%  %Cyan-s%9%ColorOff%  1080p/30fps
ECHO %Blue-s%│%ColorOff% %Cyan-s%10%ColorOff%  720p/%Red-s%60%ColorOff%fps 
ECHO %Blue-s%│%ColorOff% %Cyan-s%11%ColorOff%  720p/30fps 
ECHO %Blue-s%│%ColorOff% %Cyan-s%12%ColorOff%  480p/30fps
ECHO %Blue-s%│%ColorOff% %Cyan-s%13%ColorOff%  320p/30fps
ECHO %Blue-s%│%ColorOff% %Cyan-s%14%ColorOff%  Worst Video
ECHO %Blue-s%│%ColorOff% %Cyan-s%15%ColorOff%  Smallest Size
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%r%ColorOff%  Main Menu!padding:~1,-15!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Enter your choice: 
IF "%choice%"=="1" SET StreamAudioFormat=& SET StreamVideoFormat=1& GOTO :doYTDL-preset-stream-1
IF "%choice%"=="2" SET StreamAudioFormat=& SET StreamVideoFormat=2& GOTO :doYTDL-preset-stream-1
IF "%choice%"=="3" SET StreamAudioFormat=& SET StreamVideoFormat=3& GOTO :doYTDL-preset-stream-1
IF "%choice%"=="4" SET StreamAudioFormat=& SET VideoResolution=1440& SET VideoFPS=60& GOTO :select-codec-video-stream
IF "%choice%"=="5" SET StreamAudioFormat=& SET VideoResolution=1440& SET VideoFPS=30& GOTO :select-codec-video-stream
IF "%choice%"=="6" SET StreamAudioFormat=& SET VideoResolution=1280& SET VideoFPS=60& GOTO :select-codec-video-stream
IF "%choice%"=="7" SET StreamAudioFormat=& SET VideoResolution=1280& SET VideoFPS=30& GOTO :select-codec-video-stream
IF "%choice%"=="8" SET StreamAudioFormat=& SET VideoResolution=1080& SET VideoFPS=60& GOTO :select-codec-video-stream
IF "%choice%"=="9" SET StreamAudioFormat=& SET VideoResolution=1080& SET VideoFPS=30& GOTO :select-codec-video-stream
IF "%choice%"=="10" SET StreamAudioFormat=& SET VideoResolution=720& SET VideoFPS=60& GOTO :select-codec-video-stream
IF "%choice%"=="11" SET StreamAudioFormat=& SET VideoResolution=720& SET VideoFPS=30& GOTO :select-codec-video-stream
IF "%choice%"=="12" SET StreamAudioFormat=& SET VideoResolution=480& SET VideoFPS=30& GOTO :select-codec-video-stream
IF "%choice%"=="13" SET StreamAudioFormat=& SET VideoResolution=320& SET VideoFPS=30& GOTO :select-codec-video-stream
IF "%choice%"=="14" SET StreamAudioFormat=& SET StreamVideoFormat=4& GOTO :doYTDL-preset-stream-1
IF "%choice%"=="15" SET StreamAudioFormat=& SET StreamVideoFormat=5& GOTO :doYTDL-preset-stream-1
IF "%choice%"=="w" GOTO :select-format-stream
IF "%choice%"=="r" SET Downloaded-Video=& SET Downloaded-Audio=& SET Downloaded-Manual=& SET Downloaded-Manual-Single=& SET Downloaded-Comments=& SET Downloaded-Subs=& SET AudioQuality=& SET DownloadList=& SET VideoResolution=& SET VideoFPS=& SET CustomFormatVideo=& SET StreamAudioFormat=& SET CustomFormat-m4a=& SET CustomFormat-mp3=& SET quality_libfdk=& SET CustomFormat-opus=& SET StreamVideoFormat=& SET CommentPreset=& SET SectionsAudio=& SET SectionsVideo=& SET DoSections=& SET Downloaded-Sections=& SET Downloaded-Stream=& SET OnlyNew=& SET Downloaded-Quick=& SET SubsPreset=& SET FormatTitle=& SET CustomFormat-ogg=& SET CropThumb=& SET VariousArtists=& SET quality_simple=& SET CustomFormatAudio=& SET CustomChapters=& SET ReplayGainPreset=& SET BestAudio=& SET aac-at-param-1=& SET aac-at-param-2=& SET aac-at-param-3=& SET aac-at-param-4=& SET aac-at-param-5=& SET CustomCodec=& SET ContinueHook=& SET ALBUM=& GOTO :start
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :select-quality-video-stream

:select-codec-video-stream
SET StreamVideoFormat=
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  VIDEO CODEC!padding:~1,-17!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╯%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Any
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  AVC
ECHO %Blue-s%│%ColorOff%  %Cyan-s%3%ColorOff%  VP9
ECHO %Blue-s%│%ColorOff%  %Cyan-s%4%ColorOff%  AV1
ECHO %Blue-s%┝%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%r%ColorOff%  Main Menu!padding:~1,-15!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Select a codec: 
IF "%choice%"=="1" SET StreamVideoFormat=6& GOTO :doYTDL-preset-stream-1
IF "%choice%"=="2" SET StreamVideoFormat=7& GOTO :doYTDL-preset-stream-1
IF "%choice%"=="3" SET StreamVideoFormat=8& GOTO :doYTDL-preset-stream-1
IF "%choice%"=="4" SET StreamVideoFormat=9& GOTO :doYTDL-preset-stream-1
IF "%choice%"=="w" GOTO :select-quality-video-stream
IF "%choice%"=="r" SET Downloaded-Video=& SET Downloaded-Audio=& SET Downloaded-Manual=& SET Downloaded-Manual-Single=& SET Downloaded-Comments=& SET Downloaded-Subs=& SET AudioQuality=& SET DownloadList=& SET VideoResolution=& SET VideoFPS=& SET CustomFormatVideo=& SET StreamAudioFormat=& SET CustomFormat-m4a=& SET CustomFormat-mp3=& SET quality_libfdk=& SET CustomFormat-opus=& SET StreamVideoFormat=& SET CommentPreset=& SET SectionsAudio=& SET SectionsVideo=& SET DoSections=& SET Downloaded-Sections=& SET Downloaded-Stream=& SET OnlyNew=& SET Downloaded-Quick=& SET SubsPreset=& SET FormatTitle=& SET CustomFormat-ogg=& SET CropThumb=& SET VariousArtists=& SET quality_simple=& SET CustomFormatAudio=& SET CustomChapters=& SET ReplayGainPreset=& SET BestAudio=& SET aac-at-param-1=& SET aac-at-param-2=& SET aac-at-param-3=& SET aac-at-param-4=& SET aac-at-param-5=& SET CustomCodec=& SET ContinueHook=& SET ALBUM=& GOTO :start
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :select-codec-video-stream

::
::
:: SECTIONS MENU PART
::
::

:select-preset-sections
SET Downloaded-Sections=& SET SectionsAudio=& SET SectionsVideo=& SET CropThumb=& SET CustomChapters=
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  SECTION DOWNLOAD PRESETS!padding:~1,-30!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Audio Sections			     	      %Cyan-s%6%ColorOff%  Audio Sections + Crop Thumbnail
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  Video Sections			     	      %Cyan-s%7%ColorOff%  Video Sections + Crop Thumbnail
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%3%ColorOff%  Audio + Split By Chapters		   	      %Cyan-s%8%ColorOff%  Audio + Split By Chapters + Format Title
ECHO %Blue-s%│%ColorOff%  %Cyan-s%4%ColorOff%  Audio + Split By Chapters + Crop Thumbnail      %Cyan-s%9%ColorOff%  Audio + Split By Chapters + Crop Thumbnail + Format Title
ECHO %Blue-s%│%ColorOff%  %Cyan-s%5%ColorOff%  Video + Split By Chapters			     %Cyan-s%10%ColorOff%  Video + Split By Chapters + Crop Thumbnail
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
IF DEFINED use_pl_customchapters (
ECHO %Blue-s%│%ColorOff% %Cyan-s%11%ColorOff%  Audio + Split By Custom Chapters		     %Cyan-s%14%ColorOff%  Audio + Split By Custom Chapters + Format Title
ECHO %Blue-s%│%ColorOff% %Cyan-s%12%ColorOff%  Audio + Split By Custom Chapters + Crop Thumb  %Cyan-s%15%ColorOff%  Audio + Split By Custom Chapters + Crop Thumb + Format Title
ECHO %Blue-s%│%ColorOff% %Cyan-s%13%ColorOff%  Video + Split By Custom Chapters		     %Cyan-s%16%ColorOff%  Video + Split By Custom Chapters + Crop Thumbnail
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
)
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Select preset: 
IF "%choice%"=="1" SET SectionsAudio=1& GOTO :select-format-audio
IF "%choice%"=="2" SET SectionsVideo=1& GOTO :select-format-video
IF "%choice%"=="3" SET SectionsAudio=2& GOTO :select-format-audio
IF "%choice%"=="4" SET SectionsAudio=2& SET CropThumb=1& GOTO :select-format-audio
IF "%choice%"=="5" SET SectionsVideo=2& GOTO :select-format-video
IF "%choice%"=="6" SET SectionsAudio=1& SET CropThumb=1& GOTO :select-format-audio
IF "%choice%"=="7" SET SectionsVideo=1& SET CropThumb=1& GOTO :select-format-video
IF "%choice%"=="8" SET SectionsAudio=2& SET FormatTitle=1& GOTO :select-format-audio
IF "%choice%"=="9" SET SectionsAudio=2& SET CropThumb=1& SET FormatTitle=1& GOTO :select-format-audio
IF "%choice%"=="10" SET SectionsVideo=2& SET CropThumb=1& GOTO :select-format-video
IF "%choice%"=="11" SET CustomChapters=1& SET SectionsAudio=2& GOTO :select-format-audio
IF "%choice%"=="12" SET CustomChapters=1& SET SectionsAudio=2& SET CropThumb=1& GOTO :select-format-audio
IF "%choice%"=="13" SET CustomChapters=1& SET SectionsVideo=2& GOTO :select-format-video
IF "%choice%"=="14" SET CustomChapters=1& SET SectionsAudio=2& SET FormatTitle=1& GOTO :select-format-audio
IF "%choice%"=="15" SET CustomChapters=1& SET SectionsAudio=2& SET CropThumb=1& SET FormatTitle=1& GOTO :select-format-audio
IF "%choice%"=="16" SET CustomChapters=1& SET SectionsVideo=2& SET CropThumb=1& GOTO :select-format-video
IF "%choice%"=="w" GOTO :start
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :select-preset-sections

:select-sections-number
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  SECTIONS NUMBER!padding:~1,-21!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╯%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Set 1 Section
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  Set 2 Sections
ECHO %Blue-s%│%ColorOff%  %Cyan-s%3%ColorOff%  Set 3 Sections
ECHO %Blue-s%│%ColorOff%  %Cyan-s%4%ColorOff%  Set 4 Sections
ECHO %Blue-s%│%ColorOff%  %Cyan-s%5%ColorOff%  Set 5 Sections
ECHO %Blue-s%│%ColorOff%  %Cyan-s%6%ColorOff%  Set 6 Sections
ECHO %Blue-s%│%ColorOff%  %Cyan-s%7%ColorOff%  Set 7 Sections
ECHO %Blue-s%│%ColorOff%  %Cyan-s%8%ColorOff%  Set 8 Sections
ECHO %Blue-s%│%ColorOff%  %Cyan-s%9%ColorOff%  Set 9 Sections
ECHO %Blue-s%│%ColorOff% %Cyan-s%10%ColorOff%  Set 10 Sections
ECHO %Blue-s%┝%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%r%ColorOff%  Main Menu!padding:~1,-15!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Enter your choice: 
IF "%choice%"=="1" SET DoSections=1& GOTO :enter-sections-1
IF "%choice%"=="2" SET DoSections=2& GOTO :enter-sections-2
IF "%choice%"=="3" SET DoSections=3& GOTO :enter-sections-3
IF "%choice%"=="4" SET DoSections=4& GOTO :enter-sections-4
IF "%choice%"=="5" SET DoSections=5& GOTO :enter-sections-5
IF "%choice%"=="6" SET DoSections=6& GOTO :enter-sections-6
IF "%choice%"=="7" SET DoSections=7& GOTO :enter-sections-7
IF "%choice%"=="8" SET DoSections=8& GOTO :enter-sections-8
IF "%choice%"=="9" SET DoSections=9& GOTO :enter-sections-9
IF "%choice%"=="10" SET DoSections=10& GOTO :enter-sections-10
IF "%choice%"=="w" IF "%SectionsVideo%"=="1" (GOTO :select-codec-video) ELSE (IF "%CustomFormatAudio%"=="1" (GOTO :select-format-audio) ELSE (IF "%quality_libfdk%"=="1" (GOTO :select-quality-vbr-audio) ELSE (IF "%quality_simple%"=="1" (GOTO :select-quality-audio) ELSE (IF "%quality_aac_at%"=="1" (GOTO :select-quality-vbr-at-audio) ELSE (GOTO :select-preset-sections)))))
IF "%choice%"=="r" SET Downloaded-Video=& SET Downloaded-Audio=& SET Downloaded-Manual=& SET Downloaded-Manual-Single=& SET Downloaded-Comments=& SET Downloaded-Subs=& SET AudioQuality=& SET DownloadList=& SET VideoResolution=& SET VideoFPS=& SET CustomFormatVideo=& SET StreamAudioFormat=& SET CustomFormat-m4a=& SET CustomFormat-mp3=& SET quality_libfdk=& SET CustomFormat-opus=& SET StreamVideoFormat=& SET CommentPreset=& SET SectionsAudio=& SET SectionsVideo=& SET DoSections=& SET Downloaded-Sections=& SET Downloaded-Stream=& SET OnlyNew=& SET Downloaded-Quick=& SET SubsPreset=& SET FormatTitle=& SET CustomFormat-ogg=& SET CropThumb=& SET VariousArtists=& SET quality_simple=& SET CustomFormatAudio=& SET CustomChapters=& SET ReplayGainPreset=& SET BestAudio=& SET aac-at-param-1=& SET aac-at-param-2=& SET aac-at-param-3=& SET aac-at-param-4=& SET aac-at-param-5=& SET CustomCodec=& SET ContinueHook=& SET ALBUM=& GOTO :start
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :select-sections-number

:enter-sections-1
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  i.e. 21:00-22:00!padding:~1,-22!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
SET /P section1=%BS%   %Cyan-n%› %ColorOff% Enter section time: 
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Done!padding:~1,-10!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 1 >nul
GOTO :sections-preset-1
:enter-sections-2
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  i.e. 21:00-22:00!padding:~1,-22!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
SET /P section1=%BS%   %Cyan-n%› %ColorOff% Enter section time: 
SET /P section2=%BS%   %Cyan-n%› %ColorOff% Enter section 2 time: 
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Done!padding:~1,-10!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 1 >nul
GOTO :sections-preset-1
:enter-sections-3
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  i.e. 21:00-22:00!padding:~1,-22!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
SET /P section1=%BS%   %Cyan-n%› %ColorOff% Enter section time: 
SET /P section2=%BS%   %Cyan-n%› %ColorOff% Enter section 2 time: 
SET /P section3=%BS%   %Cyan-n%› %ColorOff% Enter section 3 time: 
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Done!padding:~1,-10!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 1 >nul
GOTO :sections-preset-1
:enter-sections-4
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  i.e. 21:00-22:00!padding:~1,-22!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
SET /P section1=%BS%   %Cyan-n%› %ColorOff% Enter section time: 
SET /P section2=%BS%   %Cyan-n%› %ColorOff% Enter section 2 time: 
SET /P section3=%BS%   %Cyan-n%› %ColorOff% Enter section 3 time: 
SET /P section4=%BS%   %Cyan-n%› %ColorOff% Enter section 4 time: 
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Done!padding:~1,-10!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 1 >nul
GOTO :sections-preset-1
:enter-sections-5
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  i.e. 21:00-22:00!padding:~1,-22!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
SET /P section1=%BS%   %Cyan-n%› %ColorOff% Enter section time: 
SET /P section2=%BS%   %Cyan-n%› %ColorOff% Enter section 2 time: 
SET /P section3=%BS%   %Cyan-n%› %ColorOff% Enter section 3 time: 
SET /P section4=%BS%   %Cyan-n%› %ColorOff% Enter section 4 time: 
SET /P section5=%BS%   %Cyan-n%› %ColorOff% Enter section 5 time: 
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Done!padding:~1,-10!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 1 >nul
GOTO :sections-preset-1
:enter-sections-6
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  i.e. 21:00-22:00!padding:~1,-22!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
SET /P section1=%BS%   %Cyan-n%› %ColorOff% Enter section time: 
SET /P section2=%BS%   %Cyan-n%› %ColorOff% Enter section 2 time: 
SET /P section3=%BS%   %Cyan-n%› %ColorOff% Enter section 3 time: 
SET /P section4=%BS%   %Cyan-n%› %ColorOff% Enter section 4 time: 
SET /P section5=%BS%   %Cyan-n%› %ColorOff% Enter section 5 time: 
SET /P section6=%BS%   %Cyan-n%› %ColorOff% Enter section 6 time: 
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Done!padding:~1,-10!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 1 >nul
GOTO :sections-preset-1
:enter-sections-7
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  i.e. 21:00-22:00!padding:~1,-22!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
SET /P section1=%BS%   %Cyan-n%› %ColorOff% Enter section time: 
SET /P section2=%BS%   %Cyan-n%› %ColorOff% Enter section 2 time: 
SET /P section3=%BS%   %Cyan-n%› %ColorOff% Enter section 3 time: 
SET /P section4=%BS%   %Cyan-n%› %ColorOff% Enter section 4 time: 
SET /P section5=%BS%   %Cyan-n%› %ColorOff% Enter section 5 time: 
SET /P section6=%BS%   %Cyan-n%› %ColorOff% Enter section 6 time: 
SET /P section7=%BS%   %Cyan-n%› %ColorOff% Enter section 7 time: 
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Done!padding:~1,-10!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 1 >nul
GOTO :sections-preset-1
:enter-sections-8
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  i.e. 21:00-22:00!padding:~1,-22!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
SET /P section1=%BS%   %Cyan-n%› %ColorOff% Enter section time: 
SET /P section2=%BS%   %Cyan-n%› %ColorOff% Enter section 2 time: 
SET /P section3=%BS%   %Cyan-n%› %ColorOff% Enter section 3 time: 
SET /P section4=%BS%   %Cyan-n%› %ColorOff% Enter section 4 time: 
SET /P section5=%BS%   %Cyan-n%› %ColorOff% Enter section 5 time: 
SET /P section6=%BS%   %Cyan-n%› %ColorOff% Enter section 6 time: 
SET /P section7=%BS%   %Cyan-n%› %ColorOff% Enter section 7 time: 
SET /P section8=%BS%   %Cyan-n%› %ColorOff% Enter section 8 time: 
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Done!padding:~1,-10!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 1 >nul
GOTO :sections-preset-1
:enter-sections-9
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  i.e. 21:00-22:00!padding:~1,-22!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
SET /P section1=%BS%   %Cyan-n%› %ColorOff% Enter section time: 
SET /P section2=%BS%   %Cyan-n%› %ColorOff% Enter section 2 time: 
SET /P section3=%BS%   %Cyan-n%› %ColorOff% Enter section 3 time: 
SET /P section4=%BS%   %Cyan-n%› %ColorOff% Enter section 4 time: 
SET /P section5=%BS%   %Cyan-n%› %ColorOff% Enter section 5 time: 
SET /P section6=%BS%   %Cyan-n%› %ColorOff% Enter section 6 time: 
SET /P section7=%BS%   %Cyan-n%› %ColorOff% Enter section 7 time: 
SET /P section8=%BS%   %Cyan-n%› %ColorOff% Enter section 8 time: 
SET /P section9=%BS%   %Cyan-n%› %ColorOff% Enter section 9 time: 
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Done!padding:~1,-10!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 1 >nul
GOTO :sections-preset-1
:enter-sections-10
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  i.e. 21:00-22:00!padding:~1,-22!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
SET /P section1=%BS%   %Cyan-n%› %ColorOff% Enter section time: 
SET /P section2=%BS%   %Cyan-n%› %ColorOff% Enter section 2 time: 
SET /P section3=%BS%   %Cyan-n%› %ColorOff% Enter section 3 time: 
SET /P section4=%BS%   %Cyan-n%› %ColorOff% Enter section 4 time: 
SET /P section5=%BS%   %Cyan-n%› %ColorOff% Enter section 5 time: 
SET /P section6=%BS%   %Cyan-n%› %ColorOff% Enter section 6 time: 
SET /P section7=%BS%   %Cyan-n%› %ColorOff% Enter section 7 time: 
SET /P section8=%BS%   %Cyan-n%› %ColorOff% Enter section 8 time: 
SET /P section9=%BS%   %Cyan-n%› %ColorOff% Enter section 9 time: 
SET /P section10=%BS%   %Cyan-n%› %ColorOff% Enter section 10 time: 
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Done!padding:~1,-10!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 1 >nul
GOTO :sections-preset-1

::
::
:: DURATION FILTER MENU
::
::

:set-duration-filter
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  DURATION FILTER PRESETS!padding:~1,-29!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╯%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Is %Blue-s%NOT%ColorOff% live + 1 Duration Filter
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  Is %Blue-s%NOT%ColorOff% live + 2 Duration Filters
ECHO %Blue-s%│%ColorOff%  %Cyan-s%3%ColorOff%  Is %Blue-s%NOT%ColorOff% live + 3 Duration Filters
ECHO %Blue-s%│%ColorOff%  %Cyan-s%4%ColorOff%  Is %Blue-s%NOT%ColorOff% live + 4 Duration Filters
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%5%ColorOff%  %Blue-s%IS%ColorOff% live + 1 Duration Filter
ECHO %Blue-s%│%ColorOff%  %Cyan-s%6%ColorOff%  %Blue-s%IS%ColorOff% live + 2 Duration Filters
ECHO %Blue-s%│%ColorOff%  %Cyan-s%7%ColorOff%  %Blue-s%IS%ColorOff% live + 3 Duration Filters
ECHO %Blue-s%│%ColorOff%  %Cyan-s%8%ColorOff%  %Blue-s%IS%ColorOff% live + 4 Duration Filters
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%9%ColorOff%  ^< 1 Minute Long
ECHO %Blue-s%│%ColorOff% %Cyan-s%10%ColorOff%  ^> 1 Minute Long
ECHO %Blue-s%│%ColorOff% %Cyan-s%11%ColorOff%  ^< 10 Minutes Long
ECHO %Blue-s%│%ColorOff% %Cyan-s%12%ColorOff%  ^> 10 Minutes Long
ECHO %Blue-s%│%ColorOff% %Cyan-s%13%ColorOff%  ^> 1 Minute %Blue-s%AND%ColorOff% ^< 10 Minutes Long
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
ECHO %Blue-s%│%ColorOff% %Cyan-s%14%ColorOff%  Video %Blue-s%IS%ColorOff% live
ECHO %Blue-s%│%ColorOff% %Cyan-s%15%ColorOff%  Video Is %Blue-s%NOT%ColorOff% live
ECHO %Blue-s%┝%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-n%r%ColorOff%  Disable Duration Filter!padding:~1,-29!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Select duration dilter preset: 
IF "%choice%"=="1" SET duration_filter=1& GOTO :duration-filter-1
IF "%choice%"=="2" SET duration_filter=2& GOTO :duration-filter-2
IF "%choice%"=="3" SET duration_filter=3& GOTO :duration-filter-3
IF "%choice%"=="4" SET duration_filter=4& GOTO :duration-filter-4
IF "%choice%"=="5" SET duration_filter=5& GOTO :duration-filter-1
IF "%choice%"=="6" SET duration_filter=6& GOTO :duration-filter-2
IF "%choice%"=="7" SET duration_filter=7& GOTO :duration-filter-3
IF "%choice%"=="8" SET duration_filter=8& GOTO :duration-filter-4
IF "%choice%"=="9" SET duration_filter=9& GOTO :settings
IF "%choice%"=="10" SET duration_filter=10& GOTO :settings
IF "%choice%"=="11" SET duration_filter=11& GOTO :settings
IF "%choice%"=="12" SET duration_filter=12& GOTO :settings
IF "%choice%"=="13" SET duration_filter=13& GOTO :settings
IF "%choice%"=="14" SET duration_filter=14& GOTO :settings
IF "%choice%"=="15" SET duration_filter=15& GOTO :settings
IF "%choice%"=="r" SET duration_filter=& GOTO :settings
IF "%choice%"=="w" GOTO :settings
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :set-duration-filter

:duration-filter-1
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  i.e. ^>60 ^(longer than 60sec^), ^<60 ^(under 60sec^), ^<=600 ^(under or equal 10mins^), ==150 ^(equal 150sec^)!padding:~1,-106!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
SET /P "duration_filter_1=%BS%   %Cyan-n%› %ColorOff% Set filter #1: "
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Done!padding:~1,-10!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 1 >nul
GOTO :settings

:duration-filter-2
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  i.e. ^>60 ^(longer than 60sec^), ^<60 ^(under 60sec^), ^<=600 ^(under or equal 10mins^), ==150 ^(equal 150sec^)!padding:~1,-106!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
SET /P "duration_filter_1=%BS%   %Cyan-n%› %ColorOff% Set filter #1: "
SET /P "duration_filter_2=%BS%   %Cyan-n%› %ColorOff% Set filter #2: "
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Done!padding:~1,-10!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 1 >nul
GOTO :settings

:duration-filter-3
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  i.e. ^>60 ^(longer than 60sec^), ^<60 ^(under 60sec^), ^<=600 ^(under or equal 10mins^), ==150 ^(equal 150sec^)!padding:~1,-106!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
SET /P "duration_filter_1=%BS%   %Cyan-n%› %ColorOff% Set filter #1: "
SET /P "duration_filter_2=%BS%   %Cyan-n%› %ColorOff% Set filter #2: "
SET /P "duration_filter_3=%BS%   %Cyan-n%› %ColorOff% Set filter #3: "
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Done!padding:~1,-10!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 1 >nul
GOTO :settings

:duration-filter-4
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  i.e. ^>60 ^(longer than 60sec^), ^<60 ^(under 60sec^), ^<=600 ^(under or equal 10mins^), ==150 ^(equal 150sec^)!padding:~1,-106!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
SET /P "duration_filter_1=%BS%   %Cyan-n%› %ColorOff% Set filter #1: "
SET /P "duration_filter_2=%BS%   %Cyan-n%› %ColorOff% Set filter #2: "
SET /P "duration_filter_3=%BS%   %Cyan-n%› %ColorOff% Set filter #3: "
SET /P "duration_filter_4=%BS%   %Cyan-n%› %ColorOff% Set filter #4: "
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Done!padding:~1,-10!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 1 >nul
GOTO :settings

::
::
:: DATE FILTER MENU
::
::

:set-date-filter
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  DATE FILTERS!padding:~1,-20!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╯%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Select Only Uploaded %Blue-s%ON%ColorOff% or %Blue-s%BEFORE%ColorOff% The Specified Date
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  Select Only Uploaded %Blue-s%ON%ColorOff% or %Blue-s%AFTER%ColorOff% The Specified Date
ECHO %Blue-s%│%ColorOff%  %Cyan-s%3%ColorOff%  Select Only Uploaded %Blue-s%BETWEEN%ColorOff% The Specified Dates
ECHO %Blue-s%│%ColorOff%  %Cyan-s%4%ColorOff%  Select Only Uploaded %Blue-s%ON CURRENT%ColorOff% Date %Blue-s%OR%ColorOff% Relative To It
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%5%ColorOff%  Select Only Uploaded %Blue-s%ON%ColorOff% or %Blue-s%BEFORE%ColorOff% The Specified Date + Set 1 Duration Filter
ECHO %Blue-s%│%ColorOff%  %Cyan-s%6%ColorOff%  Select Only Uploaded %Blue-s%ON%ColorOff% or %Blue-s%AFTER%ColorOff% The Specified Date + Set 1 Duration Filter
ECHO %Blue-s%│%ColorOff%  %Cyan-s%7%ColorOff%  Select Only Uploaded %Blue-s%BETWEEN%ColorOff% The Specified Dates + Set 1 Duration Filter
ECHO %Blue-s%│%ColorOff%  %Cyan-s%8%ColorOff%  Select Only Uploaded %Blue-s%ON CURRENT%ColorOff% Date %Blue-s%OR%ColorOff% Relative To It + Set 1 Duration Filter
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%9%ColorOff%  Select Only Uploaded %Blue-s%ON%ColorOff% or %Blue-s%BEFORE%ColorOff% The Specified Date + Set 2 Duration Filters
ECHO %Blue-s%│%ColorOff% %Cyan-s%10%ColorOff%  Select Only Uploaded %Blue-s%ON%ColorOff% or %Blue-s%AFTER%ColorOff% The Specified Date + Set 2 Duration Filters
ECHO %Blue-s%│%ColorOff% %Cyan-s%11%ColorOff%  Select Only Uploaded %Blue-s%BETWEEN%ColorOff% The Specified Dates + Set 2 Duration Filters
ECHO %Blue-s%│%ColorOff% %Cyan-s%12%ColorOff%  Select Only Uploaded %Blue-s%ON CURRENT%ColorOff% Date %Blue-s%OR%ColorOff% Relative To It + Set 2 Duration Filters
ECHO %Blue-s%┝%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-n%r%ColorOff%  Disable Date Filter!padding:~1,-25!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Select date filter preset: 
IF "%choice%"=="1" SET date-filter=1& GOTO :date-filter-1
IF "%choice%"=="2" SET date-filter=2& GOTO :date-filter-1
IF "%choice%"=="3" SET date-filter=3& GOTO :date-filter-2
IF "%choice%"=="4" SET date-filter=4& GOTO :date-filter-1
IF "%choice%"=="5" SET date-filter=5& GOTO :date-filter-3
IF "%choice%"=="6" SET date-filter=6& GOTO :date-filter-3
IF "%choice%"=="7" SET date-filter=7& GOTO :date-filter-4
IF "%choice%"=="8" SET date-filter=8& GOTO :date-filter-3
IF "%choice%"=="9" SET date-filter=9& GOTO :date-filter-5
IF "%choice%"=="10" SET date-filter=10& GOTO :date-filter-5
IF "%choice%"=="11" SET date-filter=11& GOTO :date-filter-6
IF "%choice%"=="12" SET date-filter=12& GOTO :date-filter-5
IF "%choice%"=="r" SET date-filter=& GOTO :settings
IF "%choice%"=="w" GOTO :settings
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :set-date-filter

:date-filter-1
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  Date in YYYYMMDD format OR relative period ^(now^|today^|yesterday^)[+-][0-9]^(day^|week^|month^|year^), i.e. today-6month!padding:~1,-119!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
SET /P date_filter_1=%BS%   %Cyan-n%› %ColorOff% Set date filter: 
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Done!padding:~1,-10!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 1 >nul
GOTO :settings
:date-filter-2
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  Date in YYYYMMDD format OR relative period ^(now^|today^|yesterday^)[+-][0-9]^(day^|week^|month^|year^), i.e. today-6month!padding:~1,-119!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
SET /P date_filter_1=%BS%   %Cyan-n%› %ColorOff% Set BEFORE date filter: 
SET /P date_filter_2=%BS%   %Cyan-n%› %ColorOff% Set AFTER date filter: 
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Done!padding:~1,-10!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 1 >nul
GOTO :settings
:date-filter-3
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  Date in YYYYMMDD format OR relative period ^(now^|today^|yesterday^)[+-][0-9]^(day^|week^|month^|year^), i.e. today-6month!padding:~1,-119!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
SET /P date_filter_1=%BS%   %Cyan-n%› %ColorOff% Set date filter: 
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  i.e. ^>60 ^(longer than 60sec^), ^<60 ^(under 60sec^), ^<=600 ^(under or equal 10mins^), ==150 ^(equal 150sec^)!padding:~1,-106!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
SET /P "duration_filter_1=%BS%   %Cyan-n%› %ColorOff% Set duration filter: "
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Done!padding:~1,-10!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 1 >nul
GOTO :settings
:date-filter-4
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  Date in YYYYMMDD format OR relative period ^(now^|today^|yesterday^)[+-][0-9]^(day^|week^|month^|year^), i.e. today-6month!padding:~1,-119!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
SET /P date_filter_1=%BS%   %Cyan-n%› %ColorOff% Set BEFORE date filter: 
SET /P date_filter_2=%BS%   %Cyan-n%› %ColorOff% Set AFTER date filter: 
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  i.e. ^>60 ^(longer than 60sec^), ^<60 ^(under 60sec^), ^<=600 ^(under or equal 10mins^), ==150 ^(equal 150sec^)!padding:~1,-106!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
SET /P "duration_filter_1=%BS%   %Cyan-n%› %ColorOff% Set duration filter: "
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Done!padding:~1,-10!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 1 >nul
GOTO :settings
:date-filter-5
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  Date in YYYYMMDD format OR relative period ^(now^|today^|yesterday^)[+-][0-9]^(day^|week^|month^|year^), i.e. today-6month!padding:~1,-119!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
SET /P date_filter_1=%BS%   %Cyan-n%› %ColorOff% Set date filter: 
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  i.e. ^>60 ^(longer than 60sec^), ^<60 ^(under 60sec^), ^<=600 ^(under or equal 10mins^), ==150 ^(equal 150sec^)!padding:~1,-106!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
SET /P "duration_filter_1=%BS%   %Cyan-n%› %ColorOff% Set duration filter #1: "
SET /P "duration_filter_2=%BS%   %Cyan-n%› %ColorOff% Set duration filter #2: "
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Done!padding:~1,-10!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 1 >nul
GOTO :settings
:date-filter-6
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  Date in YYYYMMDD format OR relative period ^(now^|today^|yesterday^)[+-][0-9]^(day^|week^|month^|year^), i.e. today-6month!padding:~1,-119!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
SET /P date_filter_1=%BS%   %Cyan-n%› %ColorOff% Set BEFORE date filter: 
SET /P date_filter_2=%BS%   %Cyan-n%› %ColorOff% Set AFTER date filter: 
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  i.e. ^>60 ^(longer than 60sec^), ^<60 ^(under 60sec^), ^<=600 ^(under or equal 10mins^), ==150 ^(equal 150sec^)!padding:~1,-106!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
SET /P "duration_filter_1=%BS%   %Cyan-n%› %ColorOff% Set duration filter #1: "
SET /P "duration_filter_2=%BS%   %Cyan-n%› %ColorOff% Set duration filter #2: "
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Done!padding:~1,-10!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 1 >nul
GOTO :settings

::
::
:: PROXY MENU
::
::

:proxy
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  PROXY SETTINGS!padding:~1,-20!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╯%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Set HTTP Proxy
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  Set HTTP Proxy + Authentication
ECHO %Blue-s%│%ColorOff%  %Cyan-s%3%ColorOff%  Set SOCKS Proxy
ECHO %Blue-s%│%ColorOff%  %Cyan-s%4%ColorOff%  Set SOCKS Proxy + Authentication
ECHO %Blue-s%┝%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-n%r%ColorOff%  Disable Proxies!padding:~1,-21!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Enter your choice: 
IF "%choice%"=="1" SET proxy=1& SET proxy-option=1& GOTO :proxy-1
IF "%choice%"=="2" SET proxy=1& SET proxy-option=2& GOTO :proxy-2
IF "%choice%"=="3" SET proxy=1& SET proxy-option=3& GOTO :proxy-1
IF "%choice%"=="4" SET proxy=1& SET proxy-option=4& GOTO :proxy-2
IF "%choice%"=="r" SET proxy=& SET proxy-option=& SET proxy_address=& SET proxy_username=& SET proxy_password=& IF DEFINED ContinueHook (GOTO :continue) ELSE (GOTO :settings)
IF "%choice%"=="w" IF DEFINED ContinueHook (GOTO :continue) ELSE (GOTO :settings)
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :proxy

:proxy-1
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  i.e. proxy-ip:port, localhost:9150!padding:~1,-40!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
SET /P proxy_address=%BS%   %Cyan-n%› %ColorOff% Enter proxy IP:PORT: 
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Done!padding:~1,-10!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 1 >nul
IF DEFINED ContinueHook (GOTO :continue) ELSE (GOTO :settings)

:proxy-2
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  i.e. proxy-ip:port, localhost:9150 and include your credentials!padding:~1,-69!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
SET /P proxy_address=%BS%   %Cyan-n%› %ColorOff% Enter proxy IP:PORT: 
SET /P proxy_username=%BS%   %Cyan-n%› %ColorOff% Enter your Username: 
SET /P proxy_password=%BS%   %Cyan-n%› %ColorOff% Enter your Password: 
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Done!padding:~1,-10!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 1 >nul
IF DEFINED ContinueHook (GOTO :continue) ELSE (GOTO :settings)

::
::
:: GEO BYPASS MENU
::
::

:geo-bypass
cls
ECHO %Blue-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Blue-s%•%ColorOff%  GEO-BYPASS METHODS!padding:~1,-24!%Blue-s%│%ColorOff%
ECHO %Blue-s%┝%separator:~1,-1%╯%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%1%ColorOff%  Use Default Method To Fake HTTP Header
ECHO %Blue-s%│%ColorOff%  %Cyan-s%2%ColorOff%  Use Two-Letter ISO Country Code
ECHO %Blue-s%│%ColorOff%  %Cyan-s%3%ColorOff%  Use IP Block In CIDR Notation
ECHO %Blue-s%┝%separator:~1,-1%┥%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Cyan-s%4%ColorOff%  Use HTTP Proxy
ECHO %Blue-s%│%ColorOff%  %Cyan-s%5%ColorOff%  Use HTTP Proxy + Authentication
ECHO %Blue-s%│%ColorOff%  %Cyan-s%6%ColorOff%  Use SOCKS Proxy
ECHO %Blue-s%│%ColorOff%  %Cyan-s%7%ColorOff%  Use SOCKS Proxy + Authentication
ECHO %Blue-s%┝%separator:~1,-1%╮%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-n%r%ColorOff%  Never Use Bypass!padding:~1,-22!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Yellow-s%w%ColorOff%  Go Back!padding:~1,-13!%Blue-s%│%ColorOff%
ECHO %Blue-s%│%ColorOff%  %Red-s%q%ColorOff%  Exit!padding:~1,-10!%Blue-s%│%ColorOff%
ECHO %Blue-s%╰%separator:~1,-1%╯%ColorOff%
SET /p choice=%BS%   %Cyan-n%› %ColorOff% Enter your choice: 
IF "%choice%"=="1" SET geo-bypass=default& SET geo-option=1& GOTO :settings
IF "%choice%"=="2" SET geo-bypass=1& SET geo-option=2& GOTO :geo-bypass-code
IF "%choice%"=="3" SET geo-bypass=1& SET geo-option=3& GOTO :geo-bypass-cidr
IF "%choice%"=="4" SET geo-bypass=1& SET geo-option=4& GOTO :geo-proxy-1
IF "%choice%"=="5" SET geo-bypass=1& SET geo-option=5& GOTO :geo-proxy-2
IF "%choice%"=="6" SET geo-bypass=1& SET geo-option=6& GOTO :geo-proxy-1
IF "%choice%"=="7" SET geo-bypass=1& SET geo-option=7& GOTO :geo-proxy-2
IF "%choice%"=="r" SET geo-bypass=never& SET geo-option=1& SET geo_proxy_address=& SET geo_iso_code=& SET geo_cidr=& SET geo_proxy_username=& SET geo_proxy_password=& GOTO :settings
IF "%choice%"=="w" GOTO :settings
IF "%choice%"=="q" GOTO :exit
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :geo-bypass

:geo-bypass-code
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  Specific two-letter ISO 3166-2 country code, i.e. NL for Netherlands!padding:~1,-74!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
SET /P geo_iso_code=%BS%   %Cyan-n%› %ColorOff% Enter ISO Code: 
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Done!padding:~1,-10!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 1 >nul
GOTO :settings

:geo-bypass-cidr
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  An IP block in CIDR notation, i.e. 5.104.136.0/21!padding:~1,-55!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
SET /P geo_cidr=%BS%   %Cyan-n%› %ColorOff% Enter CIDR IP notation: 
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Done!padding:~1,-10!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 1 >nul
GOTO :settings

:geo-proxy-1
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  i.e. proxy-ip:port, localhost:9150!padding:~1,-40!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
SET /P geo_proxy_address=%BS%   %Cyan-n%› %ColorOff% Enter proxy IP:PORT: 
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Done!padding:~1,-10!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 1 >nul
GOTO :settings

:geo-proxy-2
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  i.e. proxy-ip:port, localhost:9150 and include your credentials!padding:~1,-69!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
SET /P geo_proxy_address=%BS%   %Cyan-n%› %ColorOff% Enter proxy IP:PORT: 
SET /P geo_proxy_username=%BS%   %Cyan-n%› %ColorOff% Enter your Username: 
SET /P geo_proxy_password=%BS%   %Cyan-n%› %ColorOff% Enter your Password: 
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Done!padding:~1,-10!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 1 >nul
GOTO :settings

::
::
:: AUDIO PRESETS
::
::

:: AUDIO SPLIT PRESET
:doYTDL-audio-preset-1
cls
IF DEFINED format-title-auto (IF NOT DEFINED FormatTitle (IF NOT DEFINED DownloadList (
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  Defining title formating...!padding:~1,-33!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
"%YTDLP_PATH%" --no-warnings --quiet --simulate --skip-download --flat-playlist --print "%%(title)s" "%URL%" | findstr /C:" - " /C:" — " >NUL 2>&1
if %errorlevel% equ 0 SET FormatTitle=1)))
SET  OutTemplate= --path "%TARGET_FOLDER%" --output "thumbnail:%TARGET_FOLDER%\%%(artist,artists.0,creator&{} - |)s%%(album,title)s\cover.%%(ext)s" --output "chapter:%TARGET_FOLDER%\%%(artist,artists.0,creator&{} - |)s%%(album,title)s\%%(section_number&{}. |)s%%(section_title)s.%%(ext)s"
IF NOT DEFINED stop_on_error (
SET      Options=%DEBUG% --ignore-errors --ignore-config --js-runtimes "%JS_RUNTIME_NAME%:%JS_RUNTIME_PATH%" --extractor-args "youtube:%EXTRACTOR_ARGS%"
) ELSE (IF "%stop_on_error%"=="9" (
SET      Options=%DEBUG% --ignore-config --js-runtimes "%JS_RUNTIME_NAME%:%JS_RUNTIME_PATH%" --extractor-args "youtube:%EXTRACTOR_ARGS%"
) ELSE (
SET      Options=%DEBUG% --ignore-errors --ignore-config --js-runtimes "%JS_RUNTIME_NAME%:%JS_RUNTIME_PATH%" --extractor-args "youtube:%EXTRACTOR_ARGS%" --skip-playlist-after-errors %stop_on_error%
))
IF NOT DEFINED proxy (
SET      Network= --add-headers "User-Agent:%USER_AGENT%"
) ELSE (IF "%proxy-option%"=="1" (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "http://%proxy_address%"
) ELSE (IF "%proxy-option%"=="2" (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "http://%proxy_username%:%proxy_password%@%proxy_address%"
) ELSE (IF "%proxy-option%"=="3" (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "socks5://%proxy_address%"
) ELSE (IF "%proxy-option%"=="4" (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "socks5://%proxy_username%:%proxy_password%@%proxy_address%"
) ELSE (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "%PROXY%"
)))))
IF NOT DEFINED geo-bypass (
SET  GeoRestrict=
) ELSE (IF "%geo-option%"=="1" (
SET  GeoRestrict= --xff "%GEO-BYPASS%"
) ELSE (IF "%geo-option%"=="2" (
SET  GeoRestrict= --xff "%geo_iso_code%"
) ELSE (IF "%geo-option%"=="3" (
SET  GeoRestrict= --xff "%geo_cidr%"
) ELSE (IF "%geo-option%"=="4" (
SET  GeoRestrict= --geo-verification-proxy "http://%geo_proxy_address%"
) ELSE (IF "%geo-option%"=="5" (
SET  GeoRestrict= --geo-verification-proxy "http://%geo_proxy_username%:%geo_proxy_password%@%geo_proxy_address%"
) ELSE (IF "%geo-option%"=="6" (
SET  GeoRestrict= --geo-verification-proxy "socks5://%geo_proxy_address%"
) ELSE (IF "%geo-option%"=="7" (
SET  GeoRestrict= --geo-verification-proxy "socks5://%geo_proxy_username%:%geo_proxy_password%@%geo_proxy_address%"
) ELSE (
SET  GeoRestrict= --xff "%GEO-BYPASS%"
))))))))
:: Ouch, my brain
IF DEFINED use_pl_splitandtag (
    IF "%CustomChapters%"=="1" (
        IF "%OnlyNew%"=="1" (
            IF DEFINED DownloadList (
                SET Select= --download-archive "%ARCHIVE_PATH%" --extractor-args "youtube:chapters_file=%CHAPTERS_PATH%" --use-postprocessor "SplitAndTag:when=after_move;regex=%SPLIT_REGEX%" --no-playlist --compat-options no-youtube-unavailable-videos --batch-file "%URL%"
            ) ELSE (
                SET Select= --download-archive "%ARCHIVE_PATH%" --extractor-args "youtube:chapters_file=%CHAPTERS_PATH%" --use-postprocessor "SplitAndTag:when=after_move;regex=%SPLIT_REGEX%" --no-playlist --compat-options no-youtube-unavailable-videos
            )
        ) ELSE (
            SET Select= --no-download-archive --extractor-args "youtube:chapters_file=%CHAPTERS_PATH%" --use-postprocessor "SplitAndTag:when=after_move;regex=%SPLIT_REGEX%" --no-playlist --compat-options no-youtube-unavailable-videos
        )
    ) ELSE (IF "%OnlyNew%"=="1" (
            IF DEFINED DownloadList (
                SET Select= --download-archive "%ARCHIVE_PATH%" --use-postprocessor "SplitAndTag:when=after_move;regex=%SPLIT_REGEX%" --no-playlist --compat-options no-youtube-unavailable-videos --batch-file "%URL%"
            ) ELSE (
                SET Select= --download-archive "%ARCHIVE_PATH%" --use-postprocessor "SplitAndTag:when=after_move;regex=%SPLIT_REGEX%" --no-playlist --compat-options no-youtube-unavailable-videos
            )
        ) ELSE (IF DEFINED DownloadList (
                SET Select= --no-download-archive --use-postprocessor "SplitAndTag:when=after_move;regex=%SPLIT_REGEX%" --no-playlist --compat-options no-youtube-unavailable-videos --batch-file "%URL%"
            ) ELSE (
                SET Select= --no-download-archive --use-postprocessor "SplitAndTag:when=after_move;regex=%SPLIT_REGEX%" --no-playlist --compat-options no-youtube-unavailable-videos
            ))
		)
) ELSE (
    IF "%CustomChapters%"=="1" (
        IF "%OnlyNew%"=="1" (
            IF DEFINED DownloadList (
                SET Select= --download-archive "%ARCHIVE_PATH%" --extractor-args "youtube:chapters_file=%CHAPTERS_PATH%" --split-chapters --no-playlist --compat-options no-youtube-unavailable-videos --batch-file "%URL%"
            ) ELSE (
                SET Select= --download-archive "%ARCHIVE_PATH%" --extractor-args "youtube:chapters_file=%CHAPTERS_PATH%" --split-chapters --no-playlist --compat-options no-youtube-unavailable-videos
            )
        ) ELSE (
            SET Select= --no-download-archive --no-playlist --extractor-args "youtube:chapters_file=%CHAPTERS_PATH%" --split-chapters --compat-options no-youtube-unavailable-videos
        )
    ) ELSE (IF "%OnlyNew%"=="1" (
            IF DEFINED DownloadList (
                SET Select= --download-archive "%ARCHIVE_PATH%" --no-playlist --split-chapters --compat-options no-youtube-unavailable-videos --batch-file "%URL%"
            ) ELSE (
                SET Select= --download-archive "%ARCHIVE_PATH%" --no-playlist --split-chapters --compat-options no-youtube-unavailable-videos
            )
        ) ELSE (IF DEFINED DownloadList (
                SET Select= --no-download-archive --no-playlist --split-chapters --compat-options no-youtube-unavailable-videos --batch-file "%URL%"
            ) ELSE (
                SET Select= --no-download-archive --no-playlist --split-chapters --compat-options no-youtube-unavailable-videos
            ))
		)
)
IF DEFINED USEARIA (
SET     Download= --downloader "%ARIA2_PATH%" --downloader-args "aria2c: %ARIA_ARGS%" --compat-options no-external-downloader-progress
) ELSE (
SET     Download= --limit-rate %SPEED_LIMIT% --retries %RETRIES% --fragment-retries %FRAGMENT_RETRIES% --buffer-size %BUFFER_SIZE% --concurrent-fragments %THREADS%
)
SET Sponsorblock= --no-sponsorblock
SET   FileSystem= --cache-dir "%YTDLP_CACHE_DIR%" --no-mtime --ffmpeg-location "%FFMPEG_PATH%"
:: --embed-thumbnail with --split-chapters is broken https://github.com/yt-dlp/yt-dlp/issues/6225
IF "%CropThumb%"=="1" (
SET    Thumbnail= --no-embed-thumbnail --write-thumbnail --exec "after_move:\"%FFMPEG_PATH%\" -i \"%TARGET_FOLDER%\%%^^^(artist,artists.0,creator^^^&{} - ^^^|^^^)s%%^^^(album,title^^^)s\cover.webp\" -v quiet -y -c:v %FFMPEG_THUMB_FORMAT% -q:v %THUMB_COMPRESS% -vf \"crop=%CROP%\" \"%TARGET_FOLDER%\%%^^^(artist,artists.0,creator^^^&{} - ^^^|^^^)s%%^^^(album,title^^^)s\cover.%THUMB_FORMAT%\"" --exec "after_move:del /q \"%TARGET_FOLDER%\%%^^^(artist,artists.0,creator^^^&{} - ^^^|^^^)s%%^^^(album,title^^^)s\cover.webp\""
) ELSE (
SET    Thumbnail= --no-embed-thumbnail --write-thumbnail --convert-thumbnail %THUMB_FORMAT% --postprocessor-args "ThumbnailsConvertor:-q:v %THUMB_COMPRESS%"
)
SET    Verbosity= --color always --console-title --progress --progress-template ["download] [Progress":" %%(progress._percent_str)s, Speed: %%(progress._speed_str)s, Elapsed: %%(progress._elapsed_str)s, Time Remaining: %%(progress._eta_str|0)s/s"]
IF NOT DEFINED reasonable-timeouts (IF "%use_pl_returnyoutubedislike%"=="1" (
SET  WorkArounds= --use-postprocessor "ReturnYoutubeDislike:when=pre_process"
) ELSE (
SET  WorkArounds=
)) ELSE (IF "%use_pl_returnyoutubedislike%"=="1" (
SET  WorkArounds= --use-postprocessor "ReturnYoutubeDislike:when=pre_process"
) ELSE (
SET  WorkArounds=
))
IF "%CustomFormat-opus%"=="1" (
SET       Format= --extract-audio --format "774/251/250/249" --audio-format %AudioFormat%
) ELSE (IF "%CustomFormat-m4a%"=="1" (
SET       Format= --extract-audio --format "141/38/22/140/37/59/34/35/59/78/18" --audio-format %AudioFormat%
) ELSE (IF "%CustomFormat-ogg%"=="1" (
SET       Format= --extract-audio --format "46/45/44/43" --audio-format %AudioFormat%
) ELSE (IF "%CustomFormat-mp3%"=="1" (
SET       Format= --extract-audio --format "ba[acodec^=mp3]/b" --audio-format %AudioFormat%
) ELSE (IF "%CustomFormat-m4a%"=="2" (
SET       Format= --extract-audio --format "773/338/258/328/774/327/256/141/251/22/140/38/37/35/34/59/78/18/250/46/45/44/43" --audio-format %AudioFormat% --postprocessor-args "ExtractAudio:-v quiet -vn -y -threads 0 -ac 2 -ar %AUDIO_SAMPLING_RATE% -c:a libfdk_aac -vbr %AudioQuality% -cutoff %CUTOFF% -afterburner 1"
) ELSE (IF "%CustomFormat-opus%"=="2" (
SET       Format= --extract-audio --format "338/774/251/250/249" --audio-format %AudioFormat% 
) ELSE (IF "%CustomFormat-m4a%"=="3" (
SET       Format= --extract-audio --format "258/380/327/256/141/38/22/140/37/59/34/35/59/78/18" --audio-format %AudioFormat% 
) ELSE (IF "%CustomFormat-m4a%"=="4" (
SET       Format= --extract-audio --format "773/338/258/328/774/327/256/141/251/22/140/38/37/35/34/59/78/18/250/46/45/44/43" --audio-format %AudioFormat% --postprocessor-args "ExtractAudio:-v quiet -vn -y -threads 0 -c:a libfdk_aac -vbr %AudioQuality% -cutoff %CUTOFF% -afterburner 1 -af \"%FIREQUALIZER%,%LOUDNORM%,%ARESAMPLE%,%ANLMDN_DENOISING%%COMPAND%,%SILENCEREMOVE%\""
) ELSE (IF "%CustomFormat-opus%"=="3" (
SET       Format= --extract-audio --format "338/774/251/250/249" --audio-format %AudioFormat% --postprocessor-args "ExtractAudio:-v quiet -vn -y -threads 0 -b:a %AUDIO_BITRATE%k -c:a libopus -af \"%PAN%,%FIREQUALIZER%,%LOUDNORM%,%ANLMDN_DENOISING%%COMPAND%,%SILENCEREMOVE%\""
) ELSE (IF "%CustomFormat-opus%"=="4" (
SET       Format= --extract-audio --format "bestaudio[acodec^=opus]/bestaudio[container*=dash]/bestaudio" --audio-format %AudioFormat% 
) ELSE (IF "%CustomFormat-m4a%"=="5" (
SET       Format= --format "258/380/327/256/141/38/22/140/37/59/34/35/59/78/18" --audio-format %AudioFormat% --postprocessor-args "ExtractAudio:-v quiet -vn -y -threads 0 -c:a libfdk_aac -vbr %AudioQuality% -cutoff %CUTOFF% -afterburner 1 -af \"%PAN%,%FIREQUALIZER%,%LOUDNORM%,%ARESAMPLE%,%ANLMDN_DENOISING%%COMPAND%,%SILENCEREMOVE%\""
) ELSE (IF "%CustomFormat-m4a%"=="6" (
SET       Format= --extract-audio --format "773/338/258/328/774/327/256/141/251/22/140/38/37/35/34/59/78/18/250/46/45/44/43" --audio-format %AudioFormat% --postprocessor-args "ExtractAudio:-v quiet -y -vn -ac 2 -c:a aac_at %aac-at-param-1% %aac-at-param-2% %aac-at-param-3% %aac-at-param-4% %aac-at-param-5% -cutoff %CUTOFF%"
) ELSE (IF "%CustomFormat-m4a%"=="7" (
SET       Format= --extract-audio --format "773/338/258/328/774/327/256/141/251/22/140/38/37/35/34/59/78/18/250/46/45/44/43" --audio-format %AudioFormat% --postprocessor-args "ExtractAudio:-v quiet -y -vn -ac 2 -c:a aac_at %aac-at-param-1% %aac-at-param-2% %aac-at-param-3% %aac-at-param-4% %aac-at-param-5% -cutoff %CUTOFF% -af \"%FIREQUALIZER%,%LOUDNORM%,%ANLMDN_DENOISING%%COMPAND%,%SILENCEREMOVE%\""
) ELSE (IF "%CustomFormat-m4a%"=="8" (
SET       Format= --extract-audio --format "773/338/258/328/774/327/256/141/251/22/140/38/37/35/34/59/78/18/250/46/45/44/43" --audio-format %AudioFormat% --postprocessor-args "ExtractAudio:-v quiet -y -vn -c:a aac_at %aac-at-param-1% %aac-at-param-2% %aac-at-param-3% %aac-at-param-4% %aac-at-param-5% -cutoff %CUTOFF% -af \"%PAN%,%FIREQUALIZER%,%LOUDNORM%,%ARESAMPLE%,%ANLMDN_DENOISING%%COMPAND%,%SILENCEREMOVE%\""
) ELSE (IF "%BestAudio%"=="1" (
SET       Format= --extract-audio --format "773/338/258/328/774/327/256/141/251/22/140/38/37/35/34/59/78/18/250/46/45/44/43"
) ELSE (
SET       Format= --extract-audio --audio-format %AudioFormat% --audio-quality %AudioQuality%
)))))))))))))))
SET     Subtitle=
SET     Comments=
IF "%usecookies%"=="1" (
SET Authenticate= --cookies "%COOKIES_PATH%"
) ELSE (
SET Authenticate=
)
IF "%use_pl_yandextranslate%"=="2" (
SET    AdobePass= --audio-multistreams --merge-output-format mkv --use-extractors YandexTranslate --extractor-args "YandexTranslate:orig_volume=0.2:codec=libopus"
) ELSE (
SET    AdobePass=
)
:: genre from %%(tags.0)? not a good idea.
:: --parse-metadata "%%(artist,artists.0,creator,uploader)s:%%(meta_artist)s" --parse-metadata "%%(album,title)s:%%(meta_album)s"
:: --parse-metadata "%%(chapters|)l:(?P<has_chapters>.)" --match-filters "has_chapters" --parse-metadata "%%(album)s:%%(meta_album)s"  --parse-metadata "%%(artist,artists.0,creator,uploader)s:%%(meta_artist)s" 
IF "%FormatTitle%"=="1" (
SET   PreProcess= --parse-metadata "title:%%(artist)s - %%(album)s" --parse-metadata "title:%%(artist)s — %%(album)s" --parse-metadata "%%(epoch>%%Y-%%m-%%d)s:%%(meta_download_date)s" --parse-metadata "%%(album_artist,album_artists,artist,uploader)s:%%(meta_album_artist)s" --parse-metadata "%%(average_rating)s:%%(meta_rating)s" --parse-metadata "%%(composer,composers)s:%%(meta_composer)s" --parse-metadata "%%(disc_number)s:%%(meta_disc)s" --parse-metadata "%%(dislike_count)s:%%(meta_dislikes)s" --parse-metadata "%%(genre,genres)s:%%(meta_genre)s" --parse-metadata "%%(like_count)s:%%(meta_likes)s" --parse-metadata "%%(section_number,track_number|01)02d:%%(meta_track)s" --parse-metadata "%%(release_date>%%Y-%%m-%%d,release_year,upload_date>%%Y-%%m-%%d)s:%%(meta_date)s" --parse-metadata "%%(view_count)s:%%(meta_views)s" --parse-metadata "description:(?s)(?P<meta_comment>.+)" --parse-metadata ":(?P<meta_description>)" --parse-metadata ":(?P<meta_longdescription>)" --parse-metadata ":(?P<meta_synopsis>)" --parse-metadata ":(?P<meta_purl>)" --parse-metadata "webpage_url:%%(meta_www)s" --replace-in-metadata meta_album_artist " - Topic" "" --replace-in-metadata meta_date "^NA$" "" --replace-in-metadata meta_rating "^NA$" "" --replace-in-metadata meta_views "^NA$" "" --replace-in-metadata meta_likes "^NA$" "" --replace-in-metadata meta_dislikes "^NA$" "" --replace-in-metadata meta_disc "^NA$" "" --replace-in-metadata meta_composer "^NA$" "" --replace-in-metadata meta_album "^NA$" "" --replace-in-metadata meta_genre "^NA$" "" --replace-in-metadata title "/" "⁄" --replace-in-metadata title ":" "꞉" --replace-in-metadata album "/" "⁄" --replace-in-metadata album ":" "꞉"
) ELSE (
SET   PreProcess= --parse-metadata "title:%%(album)s" --parse-metadata "%%(epoch>%%Y-%%m-%%d)s:%%(meta_download_date)s" --parse-metadata "%%(album_artist,album_artists,artist,uploader)s:%%(meta_album_artist)s" --parse-metadata "%%(artist,artists.0,creator,uploader)s:%%(meta_artist)s" --parse-metadata "%%(average_rating)s:%%(meta_rating)s" --parse-metadata "%%(composer,composers)s:%%(meta_composer)s" --parse-metadata "%%(disc_number)s:%%(meta_disc)s" --parse-metadata "%%(dislike_count)s:%%(meta_dislikes)s" --parse-metadata "%%(genre,genres)s:%%(meta_genre)s" --parse-metadata "%%(like_count)s:%%(meta_likes)s" --parse-metadata "%%(section_number,track_number|01)02d:%%(meta_track)s" --parse-metadata "%%(release_date>%%Y-%%m-%%d,release_year,upload_date>%%Y-%%m-%%d)s:%%(meta_date)s" --parse-metadata "%%(view_count)s:%%(meta_views)s" --parse-metadata "description:(?s)(?P<meta_comment>.+)" --parse-metadata ":(?P<meta_description>)" --parse-metadata ":(?P<meta_longdescription>)" --parse-metadata ":(?P<meta_synopsis>)" --parse-metadata ":(?P<meta_purl>)" --parse-metadata "webpage_url:%%(meta_www)s" --replace-in-metadata meta_album_artist " - Topic" "" --replace-in-metadata meta_date "^NA$" "" --replace-in-metadata meta_rating "^NA$" "" --replace-in-metadata meta_views "^NA$" "" --replace-in-metadata meta_likes "^NA$" "" --replace-in-metadata meta_dislikes "^NA$" "" --replace-in-metadata meta_disc "^NA$" "" --replace-in-metadata meta_composer "^NA$" "" --replace-in-metadata meta_album "^NA$" "" --replace-in-metadata meta_genre "^NA$" "" --replace-in-metadata title "/" "⁄" --replace-in-metadata title ":" "꞉" --replace-in-metadata album "/" "⁄" --replace-in-metadata album ":" "꞉"
)
SET  PostProcess= --embed-metadata --no-embed-chapters --compat-options no-attach-info-json
:: --exec "after_move:del /q %%(filepath,_filename|)q"
SET   ReplayGain=
:: ReplayGain won't apply on splitted files. Can't find a variable like 'chapter_filepath' in yt-dlp's code.
REM IF NOT DEFINED use_pl_replaygain (
REM SET   ReplayGain=
REM ) ELSE (IF "%ReplayGainPreset%"=="1" (
REM SET   ReplayGain= --use-postprocessor ReplayGain:when=after_move
REM ) ELSE (IF "%ReplayGainPreset%"=="2" (
REM SET   ReplayGain= --use-postprocessor ReplayGain:when=playlist
REM ) ELSE (IF "%ReplayGainPreset%"=="3" (
REM SET   ReplayGain= --use-postprocessor ReplayGain:when=playlist;no_album=true
REM ) ELSE (IF "%ReplayGainPreset%"=="4" (
REM SET   ReplayGain= --use-postprocessor ReplayGain:when=after_move
REM ) ELSE (
REM SET   ReplayGain= --use-postprocessor ReplayGain:when=after_move
REM )))))
SET     Duration=
SET  Date_Filter=
:: setting variables for continue menu
SET Downloaded-Video=& SET Downloaded-Audio=1& SET Downloaded-Manual=& SET Downloaded-Manual-Single=& SET Downloaded-Comments=& SET Downloaded-Subs=& SET Downloaded-Sections=& SET Downloaded-Stream=& SET Downloaded-Quick=& IF "%smart_splitter%"=="2" (GOTO :doYTDL-do-smart) ELSE (GOTO :doYTDL-check)

:: AUDIO SINGLE PRESET
:doYTDL-audio-preset-2
cls
IF DEFINED format-title-auto (IF NOT DEFINED FormatTitle (IF NOT DEFINED DownloadList (
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  Defining title formating...!padding:~1,-33!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
"%YTDLP_PATH%" --no-warnings --quiet --simulate --skip-download --flat-playlist --print "%%(title)s" "%URL%" | findstr /C:" - " /C:" — " >NUL 2>&1
if %errorlevel% equ 0 SET FormatTitle=1)))
IF NOT DEFINED DownloadList (IF "%FormatTitle%"=="1" (
SET  OutTemplate= --output "%TARGET_FOLDER%\%%(uploader)s\%%(artist,artists.0,creator,uploader)s - %%(title)s.%%(ext)s"
) ELSE (
SET  OutTemplate= --output "%TARGET_FOLDER%\%%(uploader)s\%%(title)s.%%(ext)s"
)) ELSE (
SET  OutTemplate= --output "%TARGET_FOLDER%\%%(playlist_uploader,uploader)s\%%(playlist_title,playlist,meta_album|)s\%%(meta_track,autonumber+1)02d. %%(artist,artists.0,creator,uploader)s - %%(title)s.%%(ext)s"
)
IF NOT DEFINED stop_on_error (
SET      Options=%DEBUG% --ignore-errors --ignore-config --js-runtimes "%JS_RUNTIME_NAME%:%JS_RUNTIME_PATH%" --extractor-args "youtube:%EXTRACTOR_ARGS%"
) ELSE (IF "%stop_on_error%"=="9" (
SET      Options=%DEBUG% --ignore-config --js-runtimes "%JS_RUNTIME_NAME%:%JS_RUNTIME_PATH%" --extractor-args "youtube:%EXTRACTOR_ARGS%"
) ELSE (
SET      Options=%DEBUG% --ignore-errors --ignore-config --js-runtimes "%JS_RUNTIME_NAME%:%JS_RUNTIME_PATH%" --extractor-args "youtube:%EXTRACTOR_ARGS%" --skip-playlist-after-errors %stop_on_error%
))
IF NOT DEFINED proxy (
SET      Network= --add-headers "User-Agent:%USER_AGENT%"
) ELSE (IF "%proxy-option%"=="1" (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "http://%proxy_address%"
) ELSE (IF "%proxy-option%"=="2" (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "http://%proxy_username%:%proxy_password%@%proxy_address%"
) ELSE (IF "%proxy-option%"=="3" (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "socks5://%proxy_address%"
) ELSE (IF "%proxy-option%"=="4" (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "socks5://%proxy_username%:%proxy_password%@%proxy_address%"
) ELSE (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "%PROXY%"
)))))
IF NOT DEFINED geo-bypass (
SET  GeoRestrict=
) ELSE (IF "%geo-option%"=="1" (
SET  GeoRestrict= --xff "%GEO-BYPASS%"
) ELSE (IF "%geo-option%"=="2" (
SET  GeoRestrict= --xff "%geo_iso_code%"
) ELSE (IF "%geo-option%"=="3" (
SET  GeoRestrict= --xff "%geo_cidr%"
) ELSE (IF "%geo-option%"=="4" (
SET  GeoRestrict= --geo-verification-proxy "http://%geo_proxy_address%"
) ELSE (IF "%geo-option%"=="5" (
SET  GeoRestrict= --geo-verification-proxy "http://%geo_proxy_username%:%geo_proxy_password%@%geo_proxy_address%"
) ELSE (IF "%geo-option%"=="6" (
SET  GeoRestrict= --geo-verification-proxy "socks5://%geo_proxy_address%"
) ELSE (IF "%geo-option%"=="7" (
SET  GeoRestrict= --geo-verification-proxy "socks5://%geo_proxy_username%:%geo_proxy_password%@%geo_proxy_address%"
) ELSE (
SET  GeoRestrict= --xff "%GEO-BYPASS%"
))))))))
IF DEFINED OnlyNew (IF "%DownloadList%"=="1" (
SET       Select= --download-archive "%ARCHIVE_PATH%" --no-playlist --compat-options no-youtube-unavailable-videos --batch-file "%URL%"
) ELSE (
SET       Select= --download-archive "%ARCHIVE_PATH%" --no-playlist --compat-options no-youtube-unavailable-videos
)) ELSE (IF "%DownloadList%"=="1" (
SET       Select= --no-download-archive --no-playlist --compat-options no-youtube-unavailable-videos --batch-file "%URL%"
) ELSE (
SET       Select= --no-download-archive --no-playlist --compat-options no-youtube-unavailable-videos
))
IF DEFINED USEARIA (
SET     Download= --downloader "%ARIA2_PATH%" --downloader-args "aria2c: %ARIA_ARGS%" --compat-options no-external-downloader-progress
) ELSE (
SET     Download= --limit-rate %SPEED_LIMIT% --retries %RETRIES% --fragment-retries %FRAGMENT_RETRIES% --buffer-size %BUFFER_SIZE% --concurrent-fragments %THREADS%
)
SET Sponsorblock= --no-sponsorblock
SET   FileSystem= --cache-dir "%YTDLP_CACHE_DIR%" --no-mtime --ffmpeg-location "%FFMPEG_PATH%"
IF "%CropThumb%"=="1" (
SET    Thumbnail= --embed-thumbnail --convert-thumbnail %THUMB_FORMAT% --postprocessor-args "ThumbnailsConvertor+ffmpeg_o: -c:v %FFMPEG_THUMB_FORMAT% -q:v %THUMB_COMPRESS% -vf \"crop=%CROP%\""
) ELSE (
SET    Thumbnail= --embed-thumbnail --convert-thumbnail %THUMB_FORMAT% --postprocessor-args "ThumbnailsConvertor:-q:v %THUMB_COMPRESS%"
)
SET    Verbosity= --color always --console-title --progress --progress-template ["download] [Progress":" %%(progress._percent_str)s, Speed: %%(progress._speed_str)s, Elapsed: %%(progress._elapsed_str)s, Time Remaining: %%(progress._eta_str|0)s/s"]
IF NOT DEFINED reasonable-timeouts (IF "%use_pl_returnyoutubedislike%"=="1" (
SET  WorkArounds= --use-postprocessor "ReturnYoutubeDislike:when=pre_process"
) ELSE (
SET  WorkArounds=
)) ELSE (IF "%use_pl_returnyoutubedislike%"=="1" (
SET  WorkArounds= %SLEEP% --use-postprocessor "ReturnYoutubeDislike:when=pre_process"
) ELSE (
SET  WorkArounds= %SLEEP%
))
IF "%CustomFormat-opus%"=="1" (
SET       Format= --extract-audio --format "774/251/250/249"
) ELSE (IF "%CustomFormat-m4a%"=="1" (
SET       Format= --extract-audio --format "141/38/22/140/37/59/34/35/59/78/18"
) ELSE (IF "%CustomFormat-ogg%"=="1" (
SET       Format= --extract-audio --format "46/45/44/43"
) ELSE (IF "%CustomFormat-mp3%"=="1" (
SET       Format= --extract-audio --format "ba[acodec^=mp3]/b"
) ELSE (IF "%CustomFormat-m4a%"=="2" (
SET       Format= --extract-audio --format "773/338/258/328/774/327/256/141/251/22/140/38/37/35/34/59/78/18/250/46/45/44/43" --audio-format %AudioFormat% --postprocessor-args "ExtractAudio:-v quiet -vn -y -threads 0 -ac 2 -ar %AUDIO_SAMPLING_RATE% -c:a libfdk_aac -vbr %AudioQuality% -cutoff %CUTOFF% -afterburner 1"
) ELSE (IF "%CustomFormat-opus%"=="2" (
SET       Format= --extract-audio --format "338/774/251/250/249"
) ELSE (IF "%CustomFormat-m4a%"=="3" (
SET       Format= --extract-audio --format "258/380/327/256/141/38/22/140/37/59/34/35/59/78/18"
) ELSE (IF "%CustomFormat-m4a%"=="4" (
SET       Format= --extract-audio --format "773/338/258/328/774/327/256/141/251/22/140/38/37/35/34/59/78/18/250/46/45/44/43" --audio-format %AudioFormat% --postprocessor-args "ExtractAudio:-v quiet -vn -y -threads 0 -c:a libfdk_aac -vbr %AudioQuality% -cutoff %CUTOFF% -afterburner 1 -af \"%FIREQUALIZER%,%LOUDNORM%,%ARESAMPLE%,%ANLMDN_DENOISING%%COMPAND%,%SILENCEREMOVE%\""
) ELSE (IF "%CustomFormat-opus%"=="3" (
SET       Format= --extract-audio --format "338/774/251/250/249" --audio-format %AudioFormat% --postprocessor-args "ExtractAudio:-v quiet -vn -y -threads 0 -b:a %AUDIO_BITRATE%k -c:a libopus -af \"%PAN%,%FIREQUALIZER%,%LOUDNORM%,%ANLMDN_DENOISING%%COMPAND%,%SILENCEREMOVE%\""
) ELSE (IF "%CustomFormat-opus%"=="4" (
SET       Format= --extract-audio --format "bestaudio[acodec^=opus]/bestaudio[container*=dash]/bestaudio" --audio-format %AudioFormat%
) ELSE (IF "%CustomFormat-m4a%"=="5" (
SET       Format= --format "258/380/327/256/141/38/22/140/37/59/34/35/59/78/18" --audio-format %AudioFormat% --postprocessor-args "ExtractAudio:-v quiet -vn -y -threads 0 -c:a libfdk_aac -vbr %AudioQuality% -cutoff %CUTOFF% -afterburner 1 -af \"%PAN%,%FIREQUALIZER%,%LOUDNORM%,%ARESAMPLE%,%ANLMDN_DENOISING%%COMPAND%,%SILENCEREMOVE%\""
) ELSE (IF "%CustomFormat-m4a%"=="6" (
SET       Format= --extract-audio --format "773/338/258/328/774/327/256/141/251/22/140/38/37/35/34/59/78/18/250/46/45/44/43" --audio-format %AudioFormat% --postprocessor-args "ExtractAudio:-v quiet -y -vn -ac 2 -c:a aac_at %aac-at-param-1% %aac-at-param-2% %aac-at-param-3% %aac-at-param-4% %aac-at-param-5% -cutoff %CUTOFF%"
) ELSE (IF "%CustomFormat-m4a%"=="7" (
SET       Format= --extract-audio --format "773/338/258/328/774/327/256/141/251/22/140/38/37/35/34/59/78/18/250/46/45/44/43" --audio-format %AudioFormat% --postprocessor-args "ExtractAudio:-v quiet -y -vn -ac 2 -c:a aac_at %aac-at-param-1% %aac-at-param-2% %aac-at-param-3% %aac-at-param-4% %aac-at-param-5% -cutoff %CUTOFF% -af \"%FIREQUALIZER%,%LOUDNORM%,%ANLMDN_DENOISING%%COMPAND%,%SILENCEREMOVE%\""
) ELSE (IF "%CustomFormat-m4a%"=="8" (
SET       Format= --extract-audio --format "773/338/258/328/774/327/256/141/251/22/140/38/37/35/34/59/78/18/250/46/45/44/43" --audio-format %AudioFormat% --postprocessor-args "ExtractAudio:-v quiet -y -vn -c:a aac_at %aac-at-param-1% %aac-at-param-2% %aac-at-param-3% %aac-at-param-4% %aac-at-param-5% -cutoff %CUTOFF% -af \"%PAN%,%FIREQUALIZER%,%LOUDNORM%,%ARESAMPLE%,%ANLMDN_DENOISING%%COMPAND%,%SILENCEREMOVE%\""
) ELSE (IF "%BestAudio%"=="1" (
SET       Format= --extract-audio --format "773/338/258/328/774/327/256/141/251/22/140/38/37/35/34/59/78/18/250/46/45/44/43"
) ELSE (
SET       Format= --extract-audio --audio-format %AudioFormat% --audio-quality %AudioQuality%
)))))))))))))))
SET     Subtitle=
IF "%CommentPreset%"=="1" (
SET     Comments= --write-comments --extractor-args "youtube:max_comments=10;comment_sort=top" --exec before_dl:"\"%PYTHON_PATH%\" \"%YTDLP_FOLDER%\yt-dlp_nest_comments_fork.py\" -i %%(infojson_filename)#q -o %%(infojson_filename)#q.comments.html" --exec before_dl:"del /q %%(infojson_filename)#q"
) ELSE (
SET     Comments=
)
IF "%usecookies%"=="1" (
SET Authenticate= --cookies "%COOKIES_PATH%"
) ELSE (
SET Authenticate=
)
IF "%use_pl_yandextranslate%"=="2" (
SET    AdobePass= --audio-multistreams --merge-output-format mkv --use-extractors YandexTranslate --extractor-args "YandexTranslate:orig_volume=0.2:codec=libopus"
) ELSE (
SET    AdobePass=
)
IF "%FormatTitle%"=="1" (
SET   PreProcess= --parse-metadata "title:%%(artist)s - %%(title)s" --parse-metadata "title:%%(artist)s — %%(title)s" --parse-metadata "%%(epoch>%%Y-%%m-%%d)s:%%(meta_download_date)s" --parse-metadata "%%(album,playlist_title,playlist,channel)s:%%(meta_album)s" --parse-metadata "%%(album_artist,album_artists,uploader)s:%%(meta_album_artist)s" --parse-metadata "%%(average_rating)s:%%(meta_rating)s" --parse-metadata "%%(composer,composers)s:%%(meta_composer)s" --parse-metadata "%%(disc_number)s:%%(meta_disc)s" --parse-metadata "%%(dislike_count)s:%%(meta_dislikes)s" --parse-metadata "%%(genre,genres)s:%%(meta_genre)s" --parse-metadata "%%(like_count)s:%%(meta_likes)s" --parse-metadata "%%(playlist_index,track_number,autonumber+1|01)02d:%%(meta_track)s" --parse-metadata "%%(release_date>%%Y-%%m-%%d,release_year,upload_date>%%Y-%%m-%%d)s:%%(meta_date)s" --parse-metadata "%%(view_count)s:%%(meta_views)s" --parse-metadata ":(?P<meta_longdescription>)" --parse-metadata ":(?P<meta_synopsis>)" --parse-metadata ":(?P<meta_purl>)" --parse-metadata "webpage_url:%%(meta_www)s" --replace-in-metadata meta_album_artist " - Topic" "" --replace-in-metadata meta_date "^NA$" "" --replace-in-metadata meta_rating "^NA$" "" --replace-in-metadata meta_views "^NA$" "" --replace-in-metadata meta_likes "^NA$" "" --replace-in-metadata meta_dislikes "^NA$" "" --replace-in-metadata meta_disc "^NA$" "" --replace-in-metadata meta_composer "^NA$" "" --replace-in-metadata meta_album "%%(channel)s" "%%(channel)s Videos" --replace-in-metadata meta_album "^NA$" "" --replace-in-metadata meta_genre "^NA$" "" --replace-in-metadata title "/" "⁄" --replace-in-metadata title ":" "꞉" --replace-in-metadata album "/" "⁄" --replace-in-metadata album ":" "꞉"
) ELSE (  
SET   PreProcess= --parse-metadata "%%(epoch>%%Y-%%m-%%d)s:%%(meta_download_date)s" --parse-metadata "%%(album,playlist_title,playlist,channel)s:%%(meta_album)s" --parse-metadata "%%(album_artist,album_artists,uploader)s:%%(meta_album_artist)s" --parse-metadata "%%(artist,artists.0,creator,uploader)s:%%(meta_artist)s" --parse-metadata "%%(average_rating)s:%%(meta_rating)s" --parse-metadata "%%(composer,composers)s:%%(meta_composer)s" --parse-metadata "%%(disc_number)s:%%(meta_disc)s" --parse-metadata "%%(dislike_count)s:%%(meta_dislikes)s" --parse-metadata "%%(genre,genres)s:%%(meta_genre)s" --parse-metadata "%%(like_count)s:%%(meta_likes)s" --parse-metadata "%%(playlist_index,track_number,autonumber+1|01)02d:%%(meta_track)s" --parse-metadata "%%(release_date>%%Y-%%m-%%d,release_year,upload_date>%%Y-%%m-%%d)s:%%(meta_date)s" --parse-metadata "%%(view_count)s:%%(meta_views)s" --parse-metadata ":(?P<meta_longdescription>)" --parse-metadata ":(?P<meta_synopsis>)" --parse-metadata ":(?P<meta_purl>)" --parse-metadata "webpage_url:%%(meta_www)s" --replace-in-metadata meta_album_artist " - Topic" "" --replace-in-metadata meta_date "^NA$" "" --replace-in-metadata meta_rating "^NA$" "" --replace-in-metadata meta_views "^NA$" "" --replace-in-metadata meta_likes "^NA$" "" --replace-in-metadata meta_dislikes "^NA$" "" --replace-in-metadata meta_disc "^NA$" "" --replace-in-metadata meta_composer "^NA$" "" --replace-in-metadata meta_album "%%(channel)s" "%%(channel)s Videos" --replace-in-metadata meta_album "^NA$" "" --replace-in-metadata meta_genre "^NA$" "" --replace-in-metadata title "/" "⁄" --replace-in-metadata title ":" "꞉" --replace-in-metadata album "/" "⁄" --replace-in-metadata album ":" "꞉"
)
SET  PostProcess= --embed-metadata --compat-options no-attach-info-json
IF NOT DEFINED use_pl_replaygain (
SET   ReplayGain=
) ELSE (IF "%ReplayGainPreset%"=="1" (
SET   ReplayGain= --use-postprocessor ReplayGain:when=after_move
) ELSE (IF "%ReplayGainPreset%"=="2" (
SET   ReplayGain= --use-postprocessor ReplayGain:when=playlist
) ELSE (IF "%ReplayGainPreset%"=="3" (
SET   ReplayGain= --use-postprocessor ReplayGain:when=playlist;no_album=true
) ELSE (IF "%ReplayGainPreset%"=="4" (
SET   ReplayGain= --use-postprocessor ReplayGain:when=after_move
)))))
IF NOT DEFINED duration_filter (
SET     Duration=
) ELSE (IF "%duration_filter%"=="1" (
SET     Duration= --match-filters "^^^!is_live&duration%duration_filter_1%"
) ELSE (IF "%duration_filter%"=="2" (
SET     Duration= --match-filters "^^^!is_live&duration%duration_filter_1%&duration%duration_filter_2%"
) ELSE (IF "%duration_filter%"=="3" (
SET     Duration= --match-filters "^^^!is_live&duration%duration_filter_1%&duration%duration_filter_2%&duration%duration_filter_3%"
) ELSE (IF "%duration_filter%"=="4" (
SET     Duration= --match-filters "^^^!is_live&duration%duration_filter_1%&duration%duration_filter_2%&duration%duration_filter_3%&duration%duration_filter_4%"
) ELSE (IF "%duration_filter%"=="5" (
SET     Duration= --match-filters "is_live&duration%duration_filter_1%"
) ELSE (IF "%duration_filter%"=="6" (
SET     Duration= --match-filters "is_live&duration%duration_filter_1%&duration%duration_filter_2%"
) ELSE (IF "%duration_filter%"=="7" (
SET     Duration= --match-filters "is_live&duration%duration_filter_1%&duration%duration_filter_2%&duration%duration_filter_3%"
) ELSE (IF "%duration_filter%"=="8" (
SET     Duration= --match-filters "is_live&duration%duration_filter_1%&duration%duration_filter_2%&duration%duration_filter_3%&duration%duration_filter_4%"
) ELSE (IF "%duration_filter%"=="9" (
SET     Duration= --match-filters "duration<60"
) ELSE (IF "%duration_filter%"=="10" (
SET     Duration= --match-filters "duration>60"
) ELSE (IF "%duration_filter%"=="11" (
SET     Duration= --match-filters "duration<600"
) ELSE (IF "%duration_filter%"=="12" (
SET     Duration= --match-filters "duration>600"
) ELSE (IF "%duration_filter%"=="13" (
SET     Duration= --match-filters "duration>=60&duration<=600"
) ELSE (IF "%duration_filter%"=="14" (
SET     Duration= --match-filters "is_live"
) ELSE (IF "%duration_filter%"=="15" (
SET     Duration= --match-filters "^^^!is_live"
))))))))))))))))
IF NOT DEFINED date_filter (
SET  Date_Filter=
) ELSE (IF "%date_filter%"=="1" (
SET  Date_Filter= --break-match-filters "upload_date <= %date_filter_1%"
) ELSE (IF "%date_filter%"=="2" (
SET  Date_Filter= --break-match-filters "upload_date >= %date_filter_1%"
) ELSE (IF "%date_filter%"=="3" (
SET  Date_Filter= --break-match-filters "upload_date <= %date_filter_1%&upload_date >= %date_filter_2%"
) ELSE (IF "%date_filter%"=="4" (
SET  Date_Filter= --break-match-filters "upload_date == %date_filter_1%"
) ELSE (IF "%date_filter%"=="5" (
SET  Date_Filter= --break-match-filters "upload_date <= %date_filter_1%&duration%duration_filter_1%"
) ELSE (IF "%date_filter%"=="6" (
SET  Date_Filter= --break-match-filters "upload_date >= %date_filter_1%&duration%duration_filter_1%"
) ELSE (IF "%date_filter%"=="7" (
SET  Date_Filter= --break-match-filters "upload_date <= %date_filter_1%&upload_date >= %date_filter_2%&duration%duration_filter_1%"
) ELSE (IF "%date_filter%"=="8" (
SET  Date_Filter= --break-match-filters "upload_date == %date_filter_1%&duration%duration_filter_1%"
) ELSE (IF "%date_filter%"=="9" (
SET  Date_Filter= --break-match-filters "upload_date <= %date_filter_1%&duration%duration_filter_1%&duration%duration_filter_2%"
) ELSE (IF "%date_filter%"=="10" (
SET  Date_Filter= --break-match-filters "upload_date >= %date_filter_1%&duration%duration_filter_1%&duration%duration_filter_2%"
) ELSE (IF "%date_filter%"=="11" (
SET  Date_Filter= --break-match-filters "upload_date <= %date_filter_1%&upload_date >= %date_filter_2%&duration%duration_filter_1%&duration%duration_filter_2%"
) ELSE (IF "%date_filter%"=="12" (
SET  Date_Filter= --break-match-filters "upload_date == %date_filter_1%&duration%duration_filter_1%&duration%duration_filter_2%"
)))))))))))))
:: setting variables for continue menu
SET Downloaded-Video=& SET Downloaded-Audio=1& SET Downloaded-Manual=& SET Downloaded-Manual-Single=& SET Downloaded-Comments=& SET Downloaded-Subs=& SET Downloaded-Sections=& SET Downloaded-Stream=& SET Downloaded-Quick=& GOTO :doYTDL-check

:: AUDIO PLAYLIST PRESET
:doYTDL-audio-preset-3
:: an experiment to get an approximate playlist creation date
:: i'm getting the earliest date of all uploaded videos in it and setting it to a variable
IF "%VariousArtists%"=="1" (
SET  OutTemplate= --output "%TARGET_FOLDER%\%%(playlist_uploader,uploader)s\%%(playlist_title,playlist,album|)s\%%(meta_track_number,playlist_index,playlist_autonumber)02d. %%(artist,artists.0,creator,uploader)s - %%(title)s.%%(ext)s"
) ELSE (IF "%Album%"=="1" (
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  Getting the approximate playlist/album creation DATE...!padding:~1,-61!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
"%YTDLP_PATH%" --no-warnings --quiet --simulate --flat-playlist --extractor-args "youtubetab:approximate_date" --print "%%(upload_date>%%Y)s" "%URL%" | sort | "%HEAD_PATH%" -n 1 | "%TR_PATH%" -d '\012\015' | clip >NUL 2>&1
FOR /f "delims=" %%i IN ('"%PASTE_PATH%"') DO SET "playlist_date=%%i"
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Approximate DATE is %Cyan-s%%playlist_date%%ColorOff%!padding:~1,-30!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
SET  OutTemplate= --output "%TARGET_FOLDER%\%%(playlist_uploader,uploader)s\%%(%Cyan-s%%playlist_date%%ColorOff%,release_year,release_date>%%Y,upload_date>%%Y)s - %%(album,playlist_title,playlist|)s\%%(meta_track_number,playlist_index,playlist_autonumber)02d. %%(title)s.%%(ext)s" 
) ELSE (
REM %%(playlist_uploader,uploader)s\ <- this just brings yt chaos from various Topic playlists and other to your folder 
SET  OutTemplate= --output "%TARGET_FOLDER%\%%(playlist_title,playlist,album|)s\%%(playlist_index,playlist_autonumber,meta_track_number)02d. %%(title)s.%%(ext)s" 
))
IF NOT DEFINED stop_on_error (
SET      Options=%DEBUG% --ignore-errors --ignore-config --js-runtimes "%JS_RUNTIME_NAME%:%JS_RUNTIME_PATH%" --extractor-args "youtube:%EXTRACTOR_ARGS%"
) ELSE (IF "%stop_on_error%"=="9" (
SET      Options=%DEBUG% --ignore-config --js-runtimes "%JS_RUNTIME_NAME%:%JS_RUNTIME_PATH%" --extractor-args "youtube:%EXTRACTOR_ARGS%"
) ELSE (
SET      Options=%DEBUG% --ignore-errors --ignore-config --js-runtimes "%JS_RUNTIME_NAME%:%JS_RUNTIME_PATH%" --extractor-args "youtube:%EXTRACTOR_ARGS%" --skip-playlist-after-errors %stop_on_error%
))
IF NOT DEFINED proxy (
SET      Network= --add-headers "User-Agent:%USER_AGENT%"
) ELSE (IF "%proxy-option%"=="1" (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "http://%proxy_address%"
) ELSE (IF "%proxy-option%"=="2" (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "http://%proxy_username%:%proxy_password%@%proxy_address%"
) ELSE (IF "%proxy-option%"=="3" (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "socks5://%proxy_address%"
) ELSE (IF "%proxy-option%"=="4" (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "socks5://%proxy_username%:%proxy_password%@%proxy_address%"
) ELSE (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "%PROXY%"
)))))
IF NOT DEFINED geo-bypass (
SET  GeoRestrict=
) ELSE (IF "%geo-option%"=="1" (
SET  GeoRestrict= --xff "%GEO-BYPASS%"
) ELSE (IF "%geo-option%"=="2" (
SET  GeoRestrict= --xff "%geo_iso_code%"
) ELSE (IF "%geo-option%"=="3" (
SET  GeoRestrict= --xff "%geo_cidr%"
) ELSE (IF "%geo-option%"=="4" (
SET  GeoRestrict= --geo-verification-proxy "http://%geo_proxy_address%"
) ELSE (IF "%geo-option%"=="5" (
SET  GeoRestrict= --geo-verification-proxy "http://%geo_proxy_username%:%geo_proxy_password%@%geo_proxy_address%"
) ELSE (IF "%geo-option%"=="6" (
SET  GeoRestrict= --geo-verification-proxy "socks5://%geo_proxy_address%"
) ELSE (IF "%geo-option%"=="7" (
SET  GeoRestrict= --geo-verification-proxy "socks5://%geo_proxy_username%:%geo_proxy_password%@%geo_proxy_address%"
) ELSE (
SET  GeoRestrict= --xff "%GEO-BYPASS%"
))))))))
IF "%OnlyNew%"=="1" (
SET       Select= --download-archive "%ARCHIVE_PATH%" --yes-playlist --no-playlist-reverse --compat-options no-youtube-unavailable-videos
) ELSE (
SET       Select= --no-download-archive --yes-playlist --no-playlist-reverse --compat-options no-youtube-unavailable-videos
)
IF DEFINED USEARIA (
SET     Download= --downloader "%ARIA2_PATH%" --downloader-args "aria2c: %ARIA_ARGS%" --compat-options no-external-downloader-progress
) ELSE (
SET     Download= --limit-rate %SPEED_LIMIT% --retries %RETRIES% --fragment-retries %FRAGMENT_RETRIES% --buffer-size %BUFFER_SIZE% --concurrent-fragments %THREADS%
)
SET Sponsorblock= --no-sponsorblock
SET   FileSystem= --cache-dir "%YTDLP_CACHE_DIR%" --no-mtime --ffmpeg-location "%FFMPEG_PATH%"
IF "%CropThumb%"=="1" (
SET    Thumbnail= --embed-thumbnail --convert-thumbnail %THUMB_FORMAT% --postprocessor-args "ThumbnailsConvertor+ffmpeg_o: -c:v %FFMPEG_THUMB_FORMAT% -q:v %THUMB_COMPRESS% -vf \"crop=%CROP%\""
) ELSE (
SET    Thumbnail= --embed-thumbnail --convert-thumbnail %THUMB_FORMAT% --postprocessor-args "ThumbnailsConvertor:-q:v %THUMB_COMPRESS%"
)
SET    Verbosity= --color always --console-title --progress --progress-template ["download] [Progress":" %%(progress._percent_str)s, Speed: %%(progress._speed_str)s, Elapsed: %%(progress._elapsed_str)s, Time Remaining: %%(progress._eta_str|0)s/s"]
IF NOT DEFINED reasonable-timeouts (IF "%use_pl_returnyoutubedislike%"=="1" (
SET  WorkArounds= --use-postprocessor "ReturnYoutubeDislike:when=pre_process"
) ELSE (
SET  WorkArounds=
)) ELSE (IF "%use_pl_returnyoutubedislike%"=="1" (
SET  WorkArounds= %SLEEP% --use-postprocessor "ReturnYoutubeDislike:when=pre_process"
) ELSE (
SET  WorkArounds= %SLEEP%
))
IF "%CustomFormat-opus%"=="1" (
SET       Format= --extract-audio --format "774/251/250/249"
) ELSE (IF "%CustomFormat-m4a%"=="1" (
SET       Format= --extract-audio --format "141/38/22/140/37/59/34/35/59/78/18"
) ELSE (IF "%CustomFormat-ogg%"=="1" (
SET       Format= --extract-audio --format "46/45/44/43"
) ELSE (IF "%CustomFormat-mp3%"=="1" (
SET       Format= --extract-audio --format "ba[acodec^=mp3]/b"
) ELSE (IF "%CustomFormat-m4a%"=="2" (
SET       Format= --extract-audio --format "773/338/258/328/774/327/256/141/251/22/140/38/37/35/34/59/78/18/250/46/45/44/43" --audio-format %AudioFormat% --postprocessor-args "ExtractAudio:-v quiet -vn -y -threads 0 -ac 2 -ar %AUDIO_SAMPLING_RATE% -c:a libfdk_aac -vbr %AudioQuality% -cutoff %CUTOFF% -afterburner 1"
) ELSE (IF "%CustomFormat-opus%"=="2" (
SET       Format= --extract-audio --format "338/774/251/250/249"
) ELSE (IF "%CustomFormat-m4a%"=="3" (
SET       Format= --extract-audio --format "258/380/327/256/141/38/22/140/37/59/34/35/59/78/18"
) ELSE (IF "%CustomFormat-m4a%"=="4" (
SET       Format= --extract-audio --format "773/338/258/328/774/327/256/141/251/22/140/38/37/35/34/59/78/18/250/46/45/44/43" --audio-format %AudioFormat% --postprocessor-args "ExtractAudio:-v quiet -vn -y -threads 0 -c:a libfdk_aac -vbr %AudioQuality% -cutoff %CUTOFF% -afterburner 1 -af \"%FIREQUALIZER%,%LOUDNORM%,%ARESAMPLE%,%ANLMDN_DENOISING%%COMPAND%,%SILENCEREMOVE%\""
) ELSE (IF "%CustomFormat-opus%"=="3" (
SET       Format= --extract-audio --format "338/774/251/250/249" --audio-format %AudioFormat% --postprocessor-args "ExtractAudio:-v quiet -vn -y -threads 0 -b:a %AUDIO_BITRATE%k -c:a libopus -af \"%PAN%,%FIREQUALIZER%,%LOUDNORM%,%ANLMDN_DENOISING%%COMPAND%,%SILENCEREMOVE%\""
) ELSE (IF "%CustomFormat-opus%"=="4" (
SET       Format= --extract-audio --format "bestaudio[acodec^=opus]/bestaudio[container*=dash]/bestaudio" --audio-format %AudioFormat%
) ELSE (IF "%CustomFormat-m4a%"=="5" (
SET       Format= --format "258/380/327/256/141/38/22/140/37/59/34/35/59/78/18" --audio-format %AudioFormat% --postprocessor-args "ExtractAudio:-v quiet -vn -y -threads 0 -c:a libfdk_aac -vbr %AudioQuality% -cutoff %CUTOFF% -afterburner 1 -af \"%PAN%,%FIREQUALIZER%,%LOUDNORM%,%ARESAMPLE%,%ANLMDN_DENOISING%%COMPAND%,%SILENCEREMOVE%\""
) ELSE (IF "%CustomFormat-m4a%"=="6" (
SET       Format= --extract-audio --format "773/338/258/328/774/327/256/141/251/22/140/38/37/35/34/59/78/18/250/46/45/44/43" --audio-format %AudioFormat% --postprocessor-args "ExtractAudio:-v quiet -y -vn -ac 2 -c:a aac_at %aac-at-param-1% %aac-at-param-2% %aac-at-param-3% %aac-at-param-4% %aac-at-param-5% -cutoff %CUTOFF%"
) ELSE (IF "%CustomFormat-m4a%"=="7" (
SET       Format= --extract-audio --format "773/338/258/328/774/327/256/141/251/22/140/38/37/35/34/59/78/18/250/46/45/44/43" --audio-format %AudioFormat% --postprocessor-args "ExtractAudio:-v quiet -y -vn -ac 2 -c:a aac_at %aac-at-param-1% %aac-at-param-2% %aac-at-param-3% %aac-at-param-4% %aac-at-param-5% -cutoff %CUTOFF% -af \"%FIREQUALIZER%,%LOUDNORM%,%ANLMDN_DENOISING%%COMPAND%,%SILENCEREMOVE%\""
) ELSE (IF "%CustomFormat-m4a%"=="8" (
SET       Format= --extract-audio --format "773/338/258/328/774/327/256/141/251/22/140/38/37/35/34/59/78/18/250/46/45/44/43" --audio-format %AudioFormat% --postprocessor-args "ExtractAudio:-v quiet -y -vn -c:a aac_at %aac-at-param-1% %aac-at-param-2% %aac-at-param-3% %aac-at-param-4% %aac-at-param-5% -cutoff %CUTOFF% -af \"%PAN%,%FIREQUALIZER%,%LOUDNORM%,%ARESAMPLE%,%ANLMDN_DENOISING%%COMPAND%,%SILENCEREMOVE%\""
) ELSE (IF "%BestAudio%"=="1" (
SET       Format= --extract-audio --format "773/338/258/328/774/327/256/141/251/22/140/38/37/35/34/59/78/18/250/46/45/44/43"
) ELSE (
SET       Format= --extract-audio --audio-format %AudioFormat% --audio-quality %AudioQuality%
)))))))))))))))
SET     Subtitle=
SET     Comments=
IF "%usecookies%"=="1" (
SET Authenticate= --cookies "%COOKIES_PATH%"
) ELSE (
SET Authenticate=
)
IF "%use_pl_yandextranslate%"=="2" (
SET    AdobePass= --audio-multistreams --merge-output-format mkv --use-extractors YandexTranslate --extractor-args "YandexTranslate:orig_volume=0.2:codec=libopus"
) ELSE (
SET    AdobePass=
)
:: --replace-in-metadata meta_album_artist "^.*$" "Various Artists"
IF "%VariousArtists%"=="1" (
SET   PreProcess= --parse-metadata "title:%%(artist)s - %%(title)s" --parse-metadata "title:%%(artist)s — %%(title)s" --parse-metadata "%%(epoch>%%Y-%%m-%%d)s:%%(meta_download_date)s" --parse-metadata "%%(album,playlist_title)s:%%(meta_album)s" --parse-metadata "%%(album_artist|Various Artists)s:%%(meta_album_artist)s" --parse-metadata "%%(average_rating)s:%%(meta_rating)s" --parse-metadata "%%(composer,composers)s:%%(meta_composer)s" --parse-metadata "%%(disc_number)s:%%(meta_disc)s" --parse-metadata "%%(dislike_count)s:%%(meta_dislikes)s" --parse-metadata "%%(genre,genres)s:%%(meta_genre)s" --parse-metadata "%%(like_count)s:%%(meta_likes)s" --parse-metadata "%%(playlist_index,track_number,playlist_autonumber|01)02d:%%(meta_track)s" --parse-metadata "%%(release_date>%%Y-%%m-%%d,release_year,upload_date>%%Y-%%m-%%d)s:%%(meta_date)s" --parse-metadata "%%(view_count)s:%%(meta_views)s" --parse-metadata ":(?P<meta_longdescription>)" --parse-metadata ":(?P<meta_synopsis>)" --parse-metadata ":(?P<meta_purl>)" --parse-metadata "webpage_url:%%(meta_www)s" --replace-in-metadata meta_date "^NA$" "" --replace-in-metadata meta_rating "^NA$" "" --replace-in-metadata meta_views "^NA$" "" --replace-in-metadata meta_likes "^NA$" "" --replace-in-metadata meta_dislikes "^NA$" "" --replace-in-metadata meta_disc "^NA$" "" --replace-in-metadata meta_composer "^NA$" "" --replace-in-metadata meta_album "^NA$" "" --replace-in-metadata meta_genre "^NA$" "" --replace-in-metadata title "/" "⁄" --replace-in-metadata title ":" "꞉" --replace-in-metadata album "/" "⁄" --replace-in-metadata album ":" "꞉"
) ELSE (
SET   PreProcess= --parse-metadata "%%(epoch>%%Y-%%m-%%d)s:%%(meta_download_date)s" --parse-metadata "%%(album,playlist_title)s:%%(meta_album)s" --parse-metadata "%%(album_artist,album_artists,uploader)s:%%(meta_album_artist)s" --parse-metadata "%%(artist,artists.0,creator,uploader)s:%%(meta_artist)s" --parse-metadata "%%(average_rating)s:%%(meta_rating)s" --parse-metadata "%%(composer,composers)s:%%(meta_composer)s" --parse-metadata "%%(disc_number)s:%%(meta_disc)s" --parse-metadata "%%(dislike_count)s:%%(meta_dislikes)s" --parse-metadata "%%(genre,genres)s:%%(meta_genre)s" --parse-metadata "%%(like_count)s:%%(meta_likes)s" --parse-metadata "%%(playlist_index,track_number,playlist_autonumber|01)02d:%%(meta_track)s" --parse-metadata "%%(release_date>%%Y-%%m-%%d,release_year,upload_date>%%Y-%%m-%%d)s:%%(meta_date)s" --parse-metadata "%%(view_count)s:%%(meta_views)s" --parse-metadata ":(?P<meta_longdescription>)" --parse-metadata ":(?P<meta_synopsis>)" --parse-metadata ":(?P<meta_purl>)" --parse-metadata "webpage_url:%%(meta_www)s" --replace-in-metadata meta_album_artist " - Topic" "" --replace-in-metadata meta_date "^NA$" "" --replace-in-metadata meta_rating "^NA$" "" --replace-in-metadata meta_views "^NA$" "" --replace-in-metadata meta_likes "^NA$" "" --replace-in-metadata meta_dislikes "^NA$" "" --replace-in-metadata meta_disc "^NA$" "" --replace-in-metadata meta_composer "^NA$" "" --replace-in-metadata meta_album "^NA$" "" --replace-in-metadata meta_genre "^NA$" "" --replace-in-metadata title "/" "⁄" --replace-in-metadata title ":" "꞉" --replace-in-metadata album "/" "⁄" --replace-in-metadata album ":" "꞉"
)
SET  PostProcess= --embed-metadata --compat-options no-attach-info-json
IF NOT DEFINED use_pl_replaygain (
SET   ReplayGain=
) ELSE (IF "%ReplayGainPreset%"=="1" (
SET   ReplayGain= --use-postprocessor ReplayGain:when=after_move
) ELSE (IF "%ReplayGainPreset%"=="2" (
SET   ReplayGain= --use-postprocessor ReplayGain:when=playlist
) ELSE (IF "%ReplayGainPreset%"=="3" (
SET   ReplayGain= --use-postprocessor ReplayGain:when=playlist;no_album=true
) ELSE (IF "%ReplayGainPreset%"=="4" (
SET   ReplayGain= --use-postprocessor ReplayGain:when=after_move
)))))
IF NOT DEFINED duration_filter (
SET     Duration=
) ELSE (IF "%duration_filter%"=="1" (
SET     Duration= --match-filters "^^^!is_live&duration%duration_filter_1%"
) ELSE (IF "%duration_filter%"=="2" (
SET     Duration= --match-filters "^^^!is_live&duration%duration_filter_1%&duration%duration_filter_2%"
) ELSE (IF "%duration_filter%"=="3" (
SET     Duration= --match-filters "^^^!is_live&duration%duration_filter_1%&duration%duration_filter_2%&duration%duration_filter_3%"
) ELSE (IF "%duration_filter%"=="4" (
SET     Duration= --match-filters "^^^!is_live&duration%duration_filter_1%&duration%duration_filter_2%&duration%duration_filter_3%&duration%duration_filter_4%"
) ELSE (IF "%duration_filter%"=="5" (
SET     Duration= --match-filters "is_live&duration%duration_filter_1%"
) ELSE (IF "%duration_filter%"=="6" (
SET     Duration= --match-filters "is_live&duration%duration_filter_1%&duration%duration_filter_2%"
) ELSE (IF "%duration_filter%"=="7" (
SET     Duration= --match-filters "is_live&duration%duration_filter_1%&duration%duration_filter_2%&duration%duration_filter_3%"
) ELSE (IF "%duration_filter%"=="8" (
SET     Duration= --match-filters "is_live&duration%duration_filter_1%&duration%duration_filter_2%&duration%duration_filter_3%&duration%duration_filter_4%"
) ELSE (IF "%duration_filter%"=="9" (
SET     Duration= --match-filters "duration<60"
) ELSE (IF "%duration_filter%"=="10" (
SET     Duration= --match-filters "duration>60"
) ELSE (IF "%duration_filter%"=="11" (
SET     Duration= --match-filters "duration<600"
) ELSE (IF "%duration_filter%"=="12" (
SET     Duration= --match-filters "duration>600"
) ELSE (IF "%duration_filter%"=="13" (
SET     Duration= --match-filters "duration>=60&duration<=600"
) ELSE (IF "%duration_filter%"=="14" (
SET     Duration= --match-filters "is_live"
) ELSE (IF "%duration_filter%"=="15" (
SET     Duration= --match-filters "^^^!is_live"
))))))))))))))))
IF NOT DEFINED date_filter (
SET  Date_Filter=
) ELSE (IF "%date_filter%"=="1" (
SET  Date_Filter= --break-match-filters "upload_date <= %date_filter_1%"
) ELSE (IF "%date_filter%"=="2" (
SET  Date_Filter= --break-match-filters "upload_date >= %date_filter_1%"
) ELSE (IF "%date_filter%"=="3" (
SET  Date_Filter= --break-match-filters "upload_date <= %date_filter_1%&upload_date >= %date_filter_2%"
) ELSE (IF "%date_filter%"=="4" (
SET  Date_Filter= --break-match-filters "upload_date == %date_filter_1%"
) ELSE (IF "%date_filter%"=="5" (
SET  Date_Filter= --break-match-filters "upload_date <= %date_filter_1%&duration%duration_filter_1%"
) ELSE (IF "%date_filter%"=="6" (
SET  Date_Filter= --break-match-filters "upload_date >= %date_filter_1%&duration%duration_filter_1%"
) ELSE (IF "%date_filter%"=="7" (
SET  Date_Filter= --break-match-filters "upload_date <= %date_filter_1%&upload_date >= %date_filter_2%&duration%duration_filter_1%"
) ELSE (IF "%date_filter%"=="8" (
SET  Date_Filter= --break-match-filters "upload_date == %date_filter_1%&duration%duration_filter_1%"
) ELSE (IF "%date_filter%"=="9" (
SET  Date_Filter= --break-match-filters "upload_date <= %date_filter_1%&duration%duration_filter_1%&duration%duration_filter_2%"
) ELSE (IF "%date_filter%"=="10" (
SET  Date_Filter= --break-match-filters "upload_date >= %date_filter_1%&duration%duration_filter_1%&duration%duration_filter_2%"
) ELSE (IF "%date_filter%"=="11" (
SET  Date_Filter= --break-match-filters "upload_date <= %date_filter_1%&upload_date >= %date_filter_2%&duration%duration_filter_1%&duration%duration_filter_2%"
) ELSE (IF "%date_filter%"=="12" (
SET  Date_Filter= --break-match-filters "upload_date == %date_filter_1%&duration%duration_filter_1%&duration%duration_filter_2%"
)))))))))))))
:: setting variables for continue menu
SET Downloaded-Video=& SET Downloaded-Audio=1& SET Downloaded-Manual=& SET Downloaded-Manual-Single=& SET Downloaded-Comments=& SET Downloaded-Subs=& SET Downloaded-Sections=& SET Downloaded-Stream=& SET Downloaded-Quick=& GOTO :doYTDL-check

:: AUDIO QUICK PRESET
:doYTDL-preset-quick
SET  OutTemplate= --output "%TARGET_FOLDER%\%%(uploader)s\%%(artist,artists.0,creator,uploader)s - %%(title)s.%%(ext)s"
SET      Options=%DEBUG% --ignore-errors --ignore-config --js-runtimes "%JS_RUNTIME_NAME%:%JS_RUNTIME_PATH%" --extractor-args "youtube:%EXTRACTOR_ARGS%"
SET      Network= --add-headers "User-Agent:%USER_AGENT%"
SET  GeoRestrict= --xff "%GEO-BYPASS%"
SET       Select= --download-archive "%ARCHIVE_PATH%" --no-playlist --compat-options no-youtube-unavailable-videos
SET     Download= --limit-rate %SPEED_LIMIT% --retries %RETRIES% --fragment-retries %FRAGMENT_RETRIES% --buffer-size %BUFFER_SIZE% --concurrent-fragments %THREADS%
SET Sponsorblock= --no-sponsorblock
SET   FileSystem= --cache-dir "%YTDLP_CACHE_DIR%" --no-mtime --ffmpeg-location "%FFMPEG_PATH%"
SET    Thumbnail= --embed-thumbnail --convert-thumbnail %THUMB_FORMAT% --postprocessor-args "ThumbnailsConvertor+ffmpeg_o: -c:v %FFMPEG_THUMB_FORMAT% -q:v %THUMB_COMPRESS% -vf \"crop=%CROP%\""
SET    Verbosity= --color always --newline --console-title --progress --progress-template ["download] [Progress":" %%(progress._percent_str)s, Speed: %%(progress._speed_str)s, Elapsed: %%(progress._elapsed_str)s, Time Remaining: %%(progress._eta_str|0)s/s"]
SET  WorkArounds= %SLEEP%
SET       Format= --extract-audio --format "773/338/258/328/774/327/256/141/251/22/140/38/37/35/34/59/78/18/250/46/45/44/43"
SET     Subtitle=
SET     Comments=
SET Authenticate= --cookies "%COOKIES_PATH%"
SET    AdobePass=
SET   PreProcess= --parse-metadata "title:%%(artist)s - %%(title)s" --parse-metadata "title:%%(artist)s — %%(title)s" --parse-metadata "%%(epoch>%%Y-%%m-%%d)s:%%(meta_download_date)s" --parse-metadata "%%(album,playlist_title,channel)s:%%(meta_album)s" --parse-metadata "%%(album_artist,album_artists,uploader)s:%%(meta_album_artist)s" --parse-metadata "%%(average_rating)s:%%(meta_rating)s" --parse-metadata "%%(composer,composers)s:%%(meta_composer)s" --parse-metadata "%%(disc_number)s:%%(meta_disc)s" --parse-metadata "%%(dislike_count)s:%%(meta_dislikes)s" --parse-metadata "%%(genre,genres)s:%%(meta_genre)s" --parse-metadata "%%(like_count)s:%%(meta_likes)s" --parse-metadata "%%(playlist_index,track_number,playlist_autonumber|01)s:%%(meta_track)s" --parse-metadata "%%(release_date>%%Y-%%m-%%d,release_year,upload_date>%%Y-%%m-%%d)s:%%(meta_date)s" --parse-metadata "%%(view_count)s:%%(meta_views)s" --parse-metadata ":(?P<meta_longdescription>)" --parse-metadata ":(?P<meta_synopsis>)" --parse-metadata ":(?P<meta_purl>)" --parse-metadata "webpage_url:%%(meta_www)s" --replace-in-metadata meta_album_artist " - Topic" "" --replace-in-metadata meta_date "^NA$" "" --replace-in-metadata meta_rating "^NA$" "" --replace-in-metadata meta_views "^NA$" "" --replace-in-metadata meta_likes "^NA$" "" --replace-in-metadata meta_dislikes "^NA$" "" --replace-in-metadata meta_disc "^NA$" "" --replace-in-metadata meta_composer "^NA$" "" --replace-in-metadata meta_album "%%(channel)s" "%%(channel)s Videos" --replace-in-metadata meta_album "^NA$" "" --replace-in-metadata meta_genre "^NA$" "" --replace-in-metadata title "/" "⁄" --replace-in-metadata title ":" "꞉" --replace-in-metadata album "/" "⁄" --replace-in-metadata album ":" "꞉"
SET  PostProcess= --embed-metadata --compat-options no-attach-info-json
SET Downloaded-Video=& SET Downloaded-Audio=& SET Downloaded-Manual=& SET Downloaded-Manual-Single=& SET Downloaded-Comments=& SET Downloaded-Subs=& SET Downloaded-Sections=& SET Downloaded-Stream=& SET Downloaded-Quick=& GOTO :doYTDL-quick

::
::
:: VIDEO PRESETS
::
::

:: VIDEO SPLIT PRESET
:doYTDL-video-preset-1
cls
IF DEFINED format-title-auto (IF NOT DEFINED FormatTitle (IF NOT DEFINED DownloadList (
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  Defining title formating...!padding:~1,-33!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
"%YTDLP_PATH%" --no-warnings --quiet --simulate --skip-download --flat-playlist --print "%%(title)s" "%URL%" | findstr /C:" - " /C:" — " >NUL 2>&1
if %errorlevel% equ 0 SET FormatTitle=1)))
SET  OutTemplate= --path "%TARGET_FOLDER%" --output "thumbnail:%TARGET_FOLDER%\%%(artist,artists.0,creator&{} - |)s%%(album,title)s\cover.%%(ext)s" --output "chapter:%TARGET_FOLDER%\%%(artist,artists.0,creator&{} - |)s%%(album,title)s\%%(section_number&{}. |)s%%(section_title)s.%%(ext)s"
IF NOT DEFINED stop_on_error (
SET      Options=%DEBUG% --ignore-errors --ignore-config --js-runtimes "%JS_RUNTIME_NAME%:%JS_RUNTIME_PATH%" --extractor-args "youtube:%EXTRACTOR_ARGS%"
) ELSE (IF "%stop_on_error%"=="9" (
SET      Options=%DEBUG% --ignore-config --js-runtimes "%JS_RUNTIME_NAME%:%JS_RUNTIME_PATH%" --extractor-args "youtube:%EXTRACTOR_ARGS%"
) ELSE (
SET      Options=%DEBUG% --ignore-errors --ignore-config --js-runtimes "%JS_RUNTIME_NAME%:%JS_RUNTIME_PATH%" --extractor-args "youtube:%EXTRACTOR_ARGS%" --skip-playlist-after-errors %stop_on_error%
))
IF NOT DEFINED proxy (
SET      Network= --add-headers "User-Agent:%USER_AGENT%"
) ELSE (IF "%proxy-option%"=="1" (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "http://%proxy_address%"
) ELSE (IF "%proxy-option%"=="2" (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "http://%proxy_username%:%proxy_password%@%proxy_address%"
) ELSE (IF "%proxy-option%"=="3" (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "socks5://%proxy_address%"
) ELSE (IF "%proxy-option%"=="4" (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "socks5://%proxy_username%:%proxy_password%@%proxy_address%"
) ELSE (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "%PROXY%"
)))))
IF NOT DEFINED geo-bypass (
SET  GeoRestrict=
) ELSE (IF "%geo-option%"=="1" (
SET  GeoRestrict= --xff "%GEO-BYPASS%"
) ELSE (IF "%geo-option%"=="2" (
SET  GeoRestrict= --xff "%geo_iso_code%"
) ELSE (IF "%geo-option%"=="3" (
SET  GeoRestrict= --xff "%geo_cidr%"
) ELSE (IF "%geo-option%"=="4" (
SET  GeoRestrict= --geo-verification-proxy "http://%geo_proxy_address%"
) ELSE (IF "%geo-option%"=="5" (
SET  GeoRestrict= --geo-verification-proxy "http://%geo_proxy_username%:%geo_proxy_password%@%geo_proxy_address%"
) ELSE (IF "%geo-option%"=="6" (
SET  GeoRestrict= --geo-verification-proxy "socks5://%geo_proxy_address%"
) ELSE (IF "%geo-option%"=="7" (
SET  GeoRestrict= --geo-verification-proxy "socks5://%geo_proxy_username%:%geo_proxy_password%@%geo_proxy_address%"
) ELSE (
SET  GeoRestrict= --xff "%GEO-BYPASS%"
))))))))
IF DEFINED use_pl_splitandtag (
    IF "%CustomChapters%"=="1" (
        IF "%OnlyNew%"=="1" (
            IF DEFINED DownloadList (
                SET Select= --download-archive "%ARCHIVE_PATH%" --use-postprocessor "SplitAndTag:when=after_move;regex=%SPLIT_REGEX%" --no-playlist --extractor-args "youtube:chapters_file=%CHAPTERS_PATH%" --compat-options no-youtube-unavailable-videos --batch-file "%URL%"
            ) ELSE (
                SET Select= --download-archive "%ARCHIVE_PATH%" --use-postprocessor "SplitAndTag:when=after_move;regex=%SPLIT_REGEX%" --no-playlist --extractor-args "youtube:chapters_file=%CHAPTERS_PATH%" --compat-options no-youtube-unavailable-videos
            )
        ) ELSE (
            SET Select= --no-download-archive --use-postprocessor "SplitAndTag:when=after_move;regex=%SPLIT_REGEX%" --no-playlist --extractor-args "youtube:chapters_file=%CHAPTERS_PATH%" --compat-options no-youtube-unavailable-videos
        )
    ) ELSE (IF "%OnlyNew%"=="1" (
            IF DEFINED DownloadList (
                SET Select= --download-archive "%ARCHIVE_PATH%" --use-postprocessor "SplitAndTag:when=after_move;regex=%SPLIT_REGEX%" --no-playlist --compat-options no-youtube-unavailable-videos --batch-file "%URL%"
            ) ELSE (
                SET Select= --download-archive "%ARCHIVE_PATH%" --use-postprocessor "SplitAndTag:when=after_move;regex=%SPLIT_REGEX%" --no-playlist --compat-options no-youtube-unavailable-videos
            )
        ) ELSE (IF DEFINED DownloadList (
                SET Select= --no-download-archive --use-postprocessor "SplitAndTag:when=after_move;regex=%SPLIT_REGEX%" --no-playlist --compat-options no-youtube-unavailable-videos --batch-file "%URL%"
            ) ELSE (
                SET Select= --no-download-archive --use-postprocessor "SplitAndTag:when=after_move;regex=%SPLIT_REGEX%" --no-playlist --compat-options no-youtube-unavailable-videos
            ))
		)
) ELSE (
    IF "%CustomChapters%"=="1" (
        IF "%OnlyNew%"=="1" (
            IF DEFINED DownloadList (
                SET Select= --download-archive "%ARCHIVE_PATH%" --split-chapters --no-playlist --extractor-args "youtube:chapters_file=%CHAPTERS_PATH%" --compat-options no-youtube-unavailable-videos --batch-file "%URL%"
            ) ELSE (
                SET Select= --download-archive "%ARCHIVE_PATH%" --split-chapters --no-playlist --extractor-args "youtube:chapters_file=%CHAPTERS_PATH%" --compat-options no-youtube-unavailable-videos
            )
        ) ELSE (
            SET Select= --no-download-archive --no-playlist --split-chapters --extractor-args "youtube:chapters_file=%CHAPTERS_PATH%" --compat-options no-youtube-unavailable-videos
        )
    ) ELSE (IF "%OnlyNew%"=="1" (
            IF DEFINED DownloadList (
                SET Select= --download-archive "%ARCHIVE_PATH%" --no-playlist --split-chapters --compat-options no-youtube-unavailable-videos --batch-file "%URL%"
            ) ELSE (
                SET Select= --download-archive "%ARCHIVE_PATH%" --no-playlist --split-chapters --compat-options no-youtube-unavailable-videos
            )
        ) ELSE (IF DEFINED DownloadList (
                SET Select= --no-download-archive --no-playlist --split-chapters --compat-options no-youtube-unavailable-videos --batch-file "%URL%"
            ) ELSE (
                SET Select= --no-download-archive --no-playlist --split-chapters --compat-options no-youtube-unavailable-videos
            ))
		)
)
IF DEFINED USEARIA (
SET     Download= --downloader "%ARIA2_PATH%" --downloader-args "aria2c: %ARIA_ARGS%" --compat-options no-external-downloader-progress
) ELSE (
SET     Download= --limit-rate %SPEED_LIMIT% --retries %RETRIES% --fragment-retries %FRAGMENT_RETRIES% --buffer-size %BUFFER_SIZE% --concurrent-fragments %THREADS%
)
SET Sponsorblock= --sponsorblock-remove %SPONSORBLOCK_OPT%
SET   FileSystem= --cache-dir "%YTDLP_CACHE_DIR%" --no-mtime --ffmpeg-location "%FFMPEG_PATH%"
IF "%CropThumb%"=="1" (
SET    Thumbnail= --embed-thumbnail --convert-thumbnail %THUMB_FORMAT% --postprocessor-args "ThumbnailsConvertor+ffmpeg_o: -c:v %FFMPEG_THUMB_FORMAT% -q:v %THUMB_COMPRESS% -vf \"crop=%CROP%\""
) ELSE (
SET    Thumbnail= --embed-thumbnail --convert-thumbnail %THUMB_FORMAT% --postprocessor-args "ThumbnailsConvertor:-q:v %THUMB_COMPRESS%"
)
SET    Verbosity= --color always --console-title --progress --progress-template ["download] [Progress":" %%(progress._percent_str)s, Speed: %%(progress._speed_str)s, Elapsed: %%(progress._elapsed_str)s, Time Remaining: %%(progress._eta_str|0)s/s"]
IF NOT DEFINED reasonable-timeouts (IF "%use_pl_returnyoutubedislike%"=="1" (
SET  WorkArounds= --use-postprocessor "ReturnYoutubeDislike:when=pre_process"
) ELSE (
SET  WorkArounds=
)) ELSE (IF "%use_pl_returnyoutubedislike%"=="1" (
SET  WorkArounds= %SLEEP% --use-postprocessor "ReturnYoutubeDislike:when=pre_process"
) ELSE (
SET  WorkArounds= %SLEEP%
))
IF "%CustomFormatVideo%"=="1" (
SET       Format= --format "bv*+ba/b" --merge-output-format mkv
) ELSE (IF "%CustomFormatVideo%"=="2" (
SET       Format= -S "+size,+br,+res,+fps" --merge-output-format mkv
) ELSE (IF "%CustomFormatVideo%"=="3" (
SET       Format= -S "+size,+br" --merge-output-format mkv
) ELSE (IF "%CustomCodec%"=="avc" (
SET       Format= --format "(bestvideo*[vcodec~='^((he|a)vc|h26[45])'][height<=%VideoResolution%][fps<=%VideoFPS%]/bestvideo[ext=mp4]) + (bestaudio[acodec=opus][format_note*=original]/bestaudio[acodec~='^(mp?4a|aac)'][format_note*=original]/bestaudio[container*=dash]) / (bestvideo*[height<=%VideoResolution%][fps<=%VideoFPS%]+ba/b)" --merge-output-format mp4 --postprocessor-args "Merger:-v quiet -y -threads 0 -vcodec copy -b:a %AUDIO_BITRATE%k -ar %AUDIO_SAMPLING_RATE% -acodec %ENCODER% -cutoff %CUTOFF%"
) ELSE (IF "%CustomCodec%"=="vp9" (
SET       Format= --format "(bestvideo*[vcodec~='^(vp9.2|vp09|vp9)'][height<=%VideoResolution%][fps<=%VideoFPS%]/bestvideo*[height<=%VideoResolution%][fps<=%VideoFPS%]/bestvideo)+(bestaudio[acodec=opus][format_note*=original]/bestaudio[acodec~='^(mp?4a|aac)'][format_note*=original]/bestaudio[container*=dash])/(bestvideo*[height<=%VideoResolution%][fps<=%VideoFPS%]+ba/b)" --merge-output-format mkv --postprocessor-args "Merger:-v quiet -y -threads 0 -vcodec copy -b:a %AUDIO_BITRATE%k -ar %AUDIO_SAMPLING_RATE% -acodec %ENCODER% -cutoff %CUTOFF%"
) ELSE (IF "%CustomCodec%"=="av1" (
SET       Format= --format "(bestvideo*[vcodec^=av01][height<=%VideoResolution%][fps<=%VideoFPS%]/bestvideo[ext=mp4])+(bestaudio[acodec=opus][format_note*=original]/bestaudio[acodec~='^(mp?4a|aac)'][format_note*=original]/bestaudio[container*=dash]) / (bestvideo*[height<=%VideoResolution%][fps<=%VideoFPS%]+ba/b)" --merge-output-format mp4 --postprocessor-args "Merger:-v quiet -y -threads 0 -vcodec copy -b:a %AUDIO_BITRATE%k -ar %AUDIO_SAMPLING_RATE% -acodec %ENCODER% -cutoff %CUTOFF%"
) ELSE (IF "%CustomCodec%"=="any" (
SET       Format= --format "(bestvideo*[height=?%VideoResolution%][fps=?%VideoFPS%])+(bestaudio[acodec=opus][format_note*=original]/bestaudio[acodec~='^(mp?4a|aac)'][format_note*=original]/bestaudio[container*=dash])/(bestvideo*[height<=?%VideoResolution%][fps<=?%VideoFPS%]+ba/b)" --merge-output-format mkv --postprocessor-args "Merger:-v quiet -y -threads 0 -vcodec copy -b:a %AUDIO_BITRATE%k -ar %AUDIO_SAMPLING_RATE% -acodec %ENCODER% -cutoff %CUTOFF%"
)))))))
SET     Subtitle= 
SET     Comments=
IF "%usecookies%"=="1" (
SET Authenticate= --cookies "%COOKIES_PATH%"
) ELSE (
SET Authenticate=
)
IF DEFINED use_pl_yandextranslate (
SET    AdobePass= --use-extractors YandexTranslate --audio-multistreams --extractor-args YandexTranslate:orig_volume=0.3:codec=libopus
) ELSE (
SET    AdobePass=
)
IF "%FormatTitle%"=="1" (
SET   PreProcess= --parse-metadata "%%(chapters|)l:(?P<has_chapters>.)" --parse-metadata "title:%%(artist)s - %%(album)s" --parse-metadata "title:%%(artist)s — %%(album)s" --parse-metadata "%%(epoch>%%Y-%%m-%%d)s:%%(meta_download_date)s" --parse-metadata "%%(album_artist,album_artists,artist,uploader)s:%%(meta_album_artist)s" --parse-metadata "%%(artist,artists.0,creator,uploader)s:%%(meta_artist)s" --parse-metadata "%%(average_rating)s:%%(meta_rating)s" --parse-metadata "%%(composer,composers)s:%%(meta_composer)s" --parse-metadata "%%(disc_number)s:%%(meta_disc)s" --parse-metadata "%%(dislike_count)s:%%(meta_dislikes)s" --parse-metadata "%%(genre,genres)s:%%(meta_genre)s" --parse-metadata "%%(like_count)s:%%(meta_likes)s" --parse-metadata "%%(section_number,track_number|01)02d:%%(meta_track)s" --parse-metadata "%%(release_date>%%Y-%%m-%%d,release_year,upload_date>%%Y-%%m-%%d)s:%%(meta_date)s" --parse-metadata "%%(view_count)s:%%(meta_views)s" --parse-metadata "description:(?s)(?P<meta_comment>.+)" --parse-metadata ":(?P<meta_description>)" --parse-metadata ":(?P<meta_longdescription>)" --parse-metadata ":(?P<meta_synopsis>)" --parse-metadata ":(?P<meta_purl>)" --parse-metadata "webpage_url:%%(meta_www)s" --replace-in-metadata meta_album_artist " - Topic" "" --replace-in-metadata meta_date "^NA$" "" --replace-in-metadata meta_rating "^NA$" "" --replace-in-metadata meta_views "^NA$" "" --replace-in-metadata meta_likes "^NA$" "" --replace-in-metadata meta_dislikes "^NA$" "" --replace-in-metadata meta_disc "^NA$" "" --replace-in-metadata meta_composer "^NA$" "" --replace-in-metadata meta_album "^NA$" "" --replace-in-metadata meta_genre "^NA$" "" --replace-in-metadata title "/" "⁄" --replace-in-metadata title ":" "꞉" --replace-in-metadata album "/" "⁄" --replace-in-metadata album ":" "꞉"
) ELSE (
SET   PreProcess= --parse-metadata "%%(chapters|)l:(?P<has_chapters>.)" --parse-metadata "%%(epoch>%%Y-%%m-%%d)s:%%(meta_download_date)s" --parse-metadata "%%(album,playlist_title,channel)s:%%(meta_album)s" --parse-metadata "%%(album_artist,album_artists,artist,uploader)s:%%(meta_album_artist)s" --parse-metadata "%%(artist,artists.0,creator,uploader)s:%%(meta_artist)s" --parse-metadata "%%(average_rating)s:%%(meta_rating)s" --parse-metadata "%%(composer,composers)s:%%(meta_composer)s" --parse-metadata "%%(disc_number)s:%%(meta_disc)s" --parse-metadata "%%(dislike_count)s:%%(meta_dislikes)s" --parse-metadata "%%(genre,genres)s:%%(meta_genre)s" --parse-metadata "%%(like_count)s:%%(meta_likes)s" --parse-metadata "%%(section_number,track_number|01)02d:%%(meta_track)s" --parse-metadata "%%(release_date>%%Y-%%m-%%d,release_year,upload_date>%%Y-%%m-%%d)s:%%(meta_date)s" --parse-metadata "%%(view_count)s:%%(meta_views)s" --parse-metadata "description:(?s)(?P<meta_comment>.+)" --parse-metadata ":(?P<meta_description>)" --parse-metadata ":(?P<meta_longdescription>)" --parse-metadata ":(?P<meta_synopsis>)" --parse-metadata ":(?P<meta_purl>)" --parse-metadata "webpage_url:%%(meta_www)s" --replace-in-metadata meta_album_artist " - Topic" "" --replace-in-metadata meta_album "%%(channel)s" "%%(channel)s Videos" --replace-in-metadata meta_date "^NA$" "" --replace-in-metadata meta_rating "^NA$" "" --replace-in-metadata meta_views "^NA$" "" --replace-in-metadata meta_likes "^NA$" "" --replace-in-metadata meta_dislikes "^NA$" "" --replace-in-metadata meta_disc "^NA$" "" --replace-in-metadata meta_composer "^NA$" "" --replace-in-metadata meta_album "^NA$" "" --replace-in-metadata meta_genre "^NA$" "" --replace-in-metadata title "/" "⁄" --replace-in-metadata title ":" "꞉" --replace-in-metadata album "/" "⁄" --replace-in-metadata album ":" "꞉"
)
:: --embed-thumbnail with --split-chapters is broken https://github.com/yt-dlp/yt-dlp/issues/6225
SET  PostProcess= --embed-metadata --no-embed-chapters --compat-options no-attach-info-json --match-filters "has_chapters" --exec "after_move:del /q %%(filepath,_filename|)q" --force-keyframes-at-cuts --postprocessor-args "ModifyChapters+FFmpeg:-vsync cfr -preset medium -crf 21 -tune film"
SET ReplayGain=
SET Duration=
SET Date_Filter=
:: setting variables for continue menu
SET Downloaded-Video=1& SET Downloaded-Audio=& SET Downloaded-Manual=& SET Downloaded-Manual-Single=& SET Downloaded-Comments=& SET Downloaded-Subs=& SET Downloaded-Sections=& SET Downloaded-Stream=& SET Downloaded-Quick=& IF "%smart_splitter%"=="2" (GOTO :doYTDL-do-smart) ELSE (GOTO :doYTDL-check)

:: VIDEO SINGLE PRESET
:doYTDL-video-preset-2
SET  OutTemplate= --output "%TARGET_FOLDER%\%%(artists.0,artist,uploader)s - %%(title)s.%%(ext)s"
IF NOT DEFINED stop_on_error (
SET      Options=%DEBUG% --ignore-errors --ignore-config --js-runtimes "%JS_RUNTIME_NAME%:%JS_RUNTIME_PATH%" --extractor-args "youtube:%EXTRACTOR_ARGS%"
) ELSE (IF "%stop_on_error%"=="9" (
SET      Options=%DEBUG% --ignore-config --js-runtimes "%JS_RUNTIME_NAME%:%JS_RUNTIME_PATH%" --extractor-args "youtube:%EXTRACTOR_ARGS%"
) ELSE (
SET      Options=%DEBUG% --ignore-errors --ignore-config --js-runtimes "%JS_RUNTIME_NAME%:%JS_RUNTIME_PATH%" --extractor-args "youtube:%EXTRACTOR_ARGS%" --skip-playlist-after-errors %stop_on_error%
))
IF NOT DEFINED proxy (
SET      Network= --add-headers "User-Agent:%USER_AGENT%"
) ELSE (IF "%proxy-option%"=="1" (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "http://%proxy_address%"
) ELSE (IF "%proxy-option%"=="2" (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "http://%proxy_username%:%proxy_password%@%proxy_address%"
) ELSE (IF "%proxy-option%"=="3" (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "socks5://%proxy_address%"
) ELSE (IF "%proxy-option%"=="4" (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "socks5://%proxy_username%:%proxy_password%@%proxy_address%"
) ELSE (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "%PROXY%"
)))))
IF NOT DEFINED geo-bypass (
SET  GeoRestrict=
) ELSE (IF "%geo-option%"=="1" (
SET  GeoRestrict= --xff "%GEO-BYPASS%"
) ELSE (IF "%geo-option%"=="2" (
SET  GeoRestrict= --xff "%geo_iso_code%"
) ELSE (IF "%geo-option%"=="3" (
SET  GeoRestrict= --xff "%geo_cidr%"
) ELSE (IF "%geo-option%"=="4" (
SET  GeoRestrict= --geo-verification-proxy "http://%geo_proxy_address%"
) ELSE (IF "%geo-option%"=="5" (
SET  GeoRestrict= --geo-verification-proxy "http://%geo_proxy_username%:%geo_proxy_password%@%geo_proxy_address%"
) ELSE (IF "%geo-option%"=="6" (
SET  GeoRestrict= --geo-verification-proxy "socks5://%geo_proxy_address%"
) ELSE (IF "%geo-option%"=="7" (
SET  GeoRestrict= --geo-verification-proxy "socks5://%geo_proxy_username%:%geo_proxy_password%@%geo_proxy_address%"
) ELSE (
SET  GeoRestrict= --xff "%GEO-BYPASS%"
))))))))
IF DEFINED OnlyNew (IF "%DownloadList%"=="1" (
SET       Select= --download-archive "%ARCHIVE_PATH%" --no-playlist --compat-options no-youtube-unavailable-videos --batch-file "%URL%"
) ELSE (
SET       Select= --download-archive "%ARCHIVE_PATH%" --no-playlist --compat-options no-youtube-unavailable-videos
)) ELSE (IF "%DownloadList%"=="1" (
SET       Select= --no-download-archive --no-playlist --compat-options no-youtube-unavailable-videos --batch-file "%URL%"
) ELSE (
SET       Select= --no-download-archive --no-playlist --compat-options no-youtube-unavailable-videos
))
IF DEFINED USEARIA (
SET     Download= --downloader "%ARIA2_PATH%" --downloader-args "aria2c: %ARIA_ARGS%" --compat-options no-external-downloader-progress
) ELSE (
SET     Download= --limit-rate %SPEED_LIMIT% --retries %RETRIES% --fragment-retries %FRAGMENT_RETRIES% --buffer-size %BUFFER_SIZE% --concurrent-fragments %THREADS%
)
SET Sponsorblock= --sponsorblock-remove %SPONSORBLOCK_OPT%
SET   FileSystem= --cache-dir "%YTDLP_CACHE_DIR%" --no-mtime --ffmpeg-location "%FFMPEG_PATH%"
IF "%CropThumb%"=="1" (
SET    Thumbnail= --embed-thumbnail --convert-thumbnail %THUMB_FORMAT% --postprocessor-args "Merger+ffmpeg_o: -c:v %FFMPEG_THUMB_FORMAT% -q:v %THUMB_COMPRESS% -vf \"crop=%CROP%\""
) ELSE (
SET    Thumbnail= --embed-thumbnail --convert-thumbnail %THUMB_FORMAT% --postprocessor-args "ThumbnailsConvertor:-q:v %THUMB_COMPRESS%"
)
SET    Verbosity= --color always --console-title --progress --progress-template ["download] [Progress":" %%(progress._percent_str)s, Speed: %%(progress._speed_str)s, Elapsed: %%(progress._elapsed_str)s, Time Remaining: %%(progress._eta_str|0)s/s"]
IF NOT DEFINED reasonable-timeouts (IF "%use_pl_returnyoutubedislike%"=="1" (
SET  WorkArounds= --use-postprocessor "ReturnYoutubeDislike:when=pre_process"
) ELSE (
SET  WorkArounds=
)) ELSE (IF "%use_pl_returnyoutubedislike%"=="1" (
SET  WorkArounds= %SLEEP% --use-postprocessor "ReturnYoutubeDislike:when=pre_process"
) ELSE (
SET  WorkArounds= %SLEEP%
))
IF "%CustomFormatVideo%"=="1" (
SET       Format= --format "bv*+ba/b" --merge-output-format mkv
) ELSE (IF "%CustomFormatVideo%"=="2" (
SET       Format= -S "+size,+br,+res,+fps" --merge-output-format mkv
) ELSE (IF "%CustomFormatVideo%"=="3" (
SET       Format= -S "+size,+br" --merge-output-format mkv
) ELSE (IF "%CustomCodec%"=="avc" (
SET       Format= --format "(bestvideo*[vcodec~='^((he|a)vc|h26[45])'][height<=%VideoResolution%][fps<=%VideoFPS%]/bestvideo[ext=mp4]) + (bestaudio[acodec=opus][format_note*=original]/bestaudio[acodec~='^(mp?4a|aac)'][format_note*=original]/bestaudio[container*=dash]) / (bestvideo*[height<=%VideoResolution%][fps<=%VideoFPS%]+ba/b)" --merge-output-format mp4 --postprocessor-args "Merger:-v quiet -y -threads 0 -vcodec copy -b:a %AUDIO_BITRATE%k -ar %AUDIO_SAMPLING_RATE% -acodec %ENCODER% -cutoff %CUTOFF%"
) ELSE (IF "%CustomCodec%"=="vp9" (
SET       Format= --format "(bestvideo*[vcodec~='^(vp9.2|vp09|vp9)'][height<=%VideoResolution%][fps<=%VideoFPS%]/bestvideo*[height<=%VideoResolution%][fps<=%VideoFPS%]/bestvideo)+(bestaudio[acodec=opus][format_note*=original]/bestaudio[acodec~='^(mp?4a|aac)'][format_note*=original]/bestaudio[container*=dash])/(bestvideo*[height<=%VideoResolution%][fps<=%VideoFPS%]+ba/b)" --merge-output-format mkv --postprocessor-args "Merger:-v quiet -y -threads 0 -vcodec copy -b:a %AUDIO_BITRATE%k -ar %AUDIO_SAMPLING_RATE% -acodec %ENCODER% -cutoff %CUTOFF%"
) ELSE (IF "%CustomCodec%"=="av1" (
SET       Format= --format "(bestvideo*[vcodec^=av01][height<=%VideoResolution%][fps<=%VideoFPS%]/bestvideo[ext=mp4])+(bestaudio[acodec=opus][format_note*=original]/bestaudio[acodec~='^(mp?4a|aac)'][format_note*=original]/bestaudio[container*=dash]) / (bestvideo*[height<=%VideoResolution%][fps<=%VideoFPS%]+ba/b)" --merge-output-format mp4 --postprocessor-args "Merger:-v quiet -y -threads 0 -vcodec copy -b:a %AUDIO_BITRATE%k -ar %AUDIO_SAMPLING_RATE% -acodec %ENCODER% -cutoff %CUTOFF%"
) ELSE (IF "%CustomCodec%"=="any" (
SET       Format= --format "(bestvideo*[height=?%VideoResolution%][fps=?%VideoFPS%])+(bestaudio[acodec=opus][format_note*=original]/bestaudio[acodec~='^(mp?4a|aac)'][format_note*=original]/bestaudio[container*=dash])/(bestvideo*[height<=?%VideoResolution%][fps<=?%VideoFPS%]+ba/b)" --merge-output-format mkv --postprocessor-args "Merger:-v quiet -y -threads 0 -vcodec copy -b:a %AUDIO_BITRATE%k -ar %AUDIO_SAMPLING_RATE% -acodec %ENCODER% -cutoff %CUTOFF%"
)))))))
SET     Subtitle= --sub-format "%SUB_FORMAT%" --sub-langs "%SUB_LANGS%" --compat-options no-live-chat
IF "%CommentPreset%"=="1" (
SET     Comments= --write-comments --extractor-args "youtube:max_comments=50;comment_sort=top" --exec before_dl:"\"%PYTHON_PATH%\" \"%YTDLP_FOLDER%\yt-dlp_nest_comments_fork.py\" -i %%(infojson_filename)#q -o %%(infojson_filename)#q.comments.html" --exec before_dl:"del /q %%(infojson_filename)#q"
) ELSE (
SET     Comments=
)
IF "%usecookies%"=="1" (
SET Authenticate= --cookies "%COOKIES_PATH%"
) ELSE (
SET Authenticate=
)
IF DEFINED use_pl_yandextranslate (
SET    AdobePass= --use-extractors YandexTranslate --audio-multistreams --extractor-args YandexTranslate:orig_volume=0.3:codec=libopus
) ELSE (
SET    AdobePass=
)
SET   PreProcess= --parse-metadata "%%(epoch>%%Y-%%m-%%d)s:%%(meta_download_date)s" --parse-metadata "%%(album,playlist_title,playlist,channel)s:%%(meta_album)s" --parse-metadata "%%(album_artist,album_artists,uploader)s:%%(meta_album_artist)s" --parse-metadata "%%(artist,artists.0,creator,uploader)s:%%(meta_artist)s" --parse-metadata "%%(average_rating)s:%%(meta_rating)s" --parse-metadata "%%(composer,composers)s:%%(meta_composer)s" --parse-metadata "%%(disc_number)s:%%(meta_disc)s" --parse-metadata "%%(dislike_count)s:%%(meta_dislikes)s" --parse-metadata "%%(genre,genres)s:%%(meta_genre)s" --parse-metadata "%%(like_count)s:%%(meta_likes)s" --parse-metadata "%%(playlist_index,track_number,autonumber+1|01)02d:%%(meta_track)s" --parse-metadata "%%(release_date>%%Y-%%m-%%d,release_year,upload_date>%%Y-%%m-%%d)s:%%(meta_date)s" --parse-metadata "%%(view_count)s:%%(meta_views)s" --parse-metadata "description:(?s)(?P<meta_comment>.+)" --parse-metadata ":(?P<meta_description>)" --parse-metadata ":(?P<meta_longdescription>)" --parse-metadata ":(?P<meta_synopsis>)" --parse-metadata ":(?P<meta_purl>)" --parse-metadata "webpage_url:%%(meta_www)s" --replace-in-metadata meta_album_artist " - Topic" "" --replace-in-metadata meta_date "^NA$" "" --replace-in-metadata meta_rating "^NA$" "" --replace-in-metadata meta_views "^NA$" "" --replace-in-metadata meta_likes "^NA$" "" --replace-in-metadata meta_dislikes "^NA$" "" --replace-in-metadata meta_disc "^NA$" "" --replace-in-metadata meta_composer "^NA$" "" --replace-in-metadata meta_album "%%(uploader)s" "%%(uploader)s Videos" --replace-in-metadata meta_album "^NA$" "" --replace-in-metadata meta_genre "^NA$" "" --replace-in-metadata title "/" "⁄" --replace-in-metadata title ":" "꞉" --replace-in-metadata album "/" "⁄" --replace-in-metadata album ":" "꞉"
SET  PostProcess= --embed-metadata --embed-chapters --embed-subs --compat-options no-attach-info-json
SET   ReplayGain=
IF NOT DEFINED duration_filter (
SET     Duration=
) ELSE (IF "%duration_filter%"=="1" (
SET     Duration= --match-filters "^^^!is_live&duration%duration_filter_1%"
) ELSE (IF "%duration_filter%"=="2" (
SET     Duration= --match-filters "^^^!is_live&duration%duration_filter_1%&duration%duration_filter_2%"
) ELSE (IF "%duration_filter%"=="3" (
SET     Duration= --match-filters "^^^!is_live&duration%duration_filter_1%&duration%duration_filter_2%&duration%duration_filter_3%"
) ELSE (IF "%duration_filter%"=="4" (
SET     Duration= --match-filters "^^^!is_live&duration%duration_filter_1%&duration%duration_filter_2%&duration%duration_filter_3%&duration%duration_filter_4%"
) ELSE (IF "%duration_filter%"=="5" (
SET     Duration= --match-filters "is_live&duration%duration_filter_1%"
) ELSE (IF "%duration_filter%"=="6" (
SET     Duration= --match-filters "is_live&duration%duration_filter_1%&duration%duration_filter_2%"
) ELSE (IF "%duration_filter%"=="7" (
SET     Duration= --match-filters "is_live&duration%duration_filter_1%&duration%duration_filter_2%&duration%duration_filter_3%"
) ELSE (IF "%duration_filter%"=="8" (
SET     Duration= --match-filters "is_live&duration%duration_filter_1%&duration%duration_filter_2%&duration%duration_filter_3%&duration%duration_filter_4%"
) ELSE (IF "%duration_filter%"=="9" (
SET     Duration= --match-filters "duration<60"
) ELSE (IF "%duration_filter%"=="10" (
SET     Duration= --match-filters "duration>60"
) ELSE (IF "%duration_filter%"=="11" (
SET     Duration= --match-filters "duration<600"
) ELSE (IF "%duration_filter%"=="12" (
SET     Duration= --match-filters "duration>600"
) ELSE (IF "%duration_filter%"=="13" (
SET     Duration= --match-filters "duration>=60&duration<=600"
) ELSE (IF "%duration_filter%"=="14" (
SET     Duration= --match-filters "is_live"
) ELSE (IF "%duration_filter%"=="15" (
SET     Duration= --match-filters "^^^!is_live"
))))))))))))))))
IF NOT DEFINED date_filter (
SET  Date_Filter=
) ELSE (IF "%date_filter%"=="1" (
SET  Date_Filter= --break-match-filters "upload_date <= %date_filter_1%"
) ELSE (IF "%date_filter%"=="2" (
SET  Date_Filter= --break-match-filters "upload_date >= %date_filter_1%"
) ELSE (IF "%date_filter%"=="3" (
SET  Date_Filter= --break-match-filters "upload_date <= %date_filter_1%&upload_date >= %date_filter_2%"
) ELSE (IF "%date_filter%"=="4" (
SET  Date_Filter= --break-match-filters "upload_date == %date_filter_1%"
) ELSE (IF "%date_filter%"=="5" (
SET  Date_Filter= --break-match-filters "upload_date <= %date_filter_1%&duration%duration_filter_1%"
) ELSE (IF "%date_filter%"=="6" (
SET  Date_Filter= --break-match-filters "upload_date >= %date_filter_1%&duration%duration_filter_1%"
) ELSE (IF "%date_filter%"=="7" (
SET  Date_Filter= --break-match-filters "upload_date <= %date_filter_1%&upload_date >= %date_filter_2%&duration%duration_filter_1%"
) ELSE (IF "%date_filter%"=="8" (
SET  Date_Filter= --break-match-filters "upload_date == %date_filter_1%&duration%duration_filter_1%"
) ELSE (IF "%date_filter%"=="9" (
SET  Date_Filter= --break-match-filters "upload_date <= %date_filter_1%&duration%duration_filter_1%&duration%duration_filter_2%"
) ELSE (IF "%date_filter%"=="10" (
SET  Date_Filter= --break-match-filters "upload_date >= %date_filter_1%&duration%duration_filter_1%&duration%duration_filter_2%"
) ELSE (IF "%date_filter%"=="11" (
SET  Date_Filter= --break-match-filters "upload_date <= %date_filter_1%&upload_date >= %date_filter_2%&duration%duration_filter_1%&duration%duration_filter_2%"
) ELSE (IF "%date_filter%"=="12" (
SET  Date_Filter= --break-match-filters "upload_date == %date_filter_1%&duration%duration_filter_1%&duration%duration_filter_2%"
)))))))))))))
:: setting variables for continue menu
SET Downloaded-Video=1& SET Downloaded-Audio=& SET Downloaded-Manual=& SET Downloaded-Manual-Single=& SET Downloaded-Comments=& SET Downloaded-Subs=& SET Downloaded-Sections=& SET Downloaded-Stream=& SET Downloaded-Quick=& GOTO :doYTDL-check

:: VIDEO PLAYLIST PRESET
:doYTDL-video-preset-3
IF "%VariousArtists%"=="1" (
SET  OutTemplate= --output "%TARGET_FOLDER%\%%(playlist_uploader,uploader)s\%%(playlist_title,playlist,album|)s\%%(meta_track_number,playlist_index,playlist_autonumber)02d. %%(artist,artists.0,creator,uploader)s - %%(title)s.%%(ext)s"
) ELSE (IF "%Album%"=="1" (
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  Getting the approximate playlist/album creation DATE...!padding:~1,-61!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
"%YTDLP_PATH%" --no-warnings --quiet --simulate --flat-playlist --extractor-args "youtubetab:approximate_date" --print "%%(upload_date>%%Y)s" "%URL%" | sort | "%HEAD_PATH%" -n 1 | "%TR_PATH%" -d '\012\015' | clip >NUL 2>&1
FOR /f "delims=" %%i IN ('"%PASTE_PATH%"') DO SET "playlist_date=%%i"
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Approximate DATE is %Cyan-s%%playlist_date%%ColorOff%!padding:~1,-30!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
SET  OutTemplate= --output "%TARGET_FOLDER%\%%(playlist_uploader,uploader)s\%%(%Cyan-s%%playlist_date%%ColorOff%,release_year,release_date>%%Y,upload_date>%%Y)s - %%(album,playlist_title,playlist|)s\%%(meta_track_number,playlist_index,playlist_autonumber)02d. %%(title)s.%%(ext)s" 
) ELSE (
REM %%(playlist_uploader,uploader)s\
SET  OutTemplate= --output "%TARGET_FOLDER%\%%(playlist_title,playlist,album|)s\%%(playlist_index,playlist_autonumber,meta_track_number)02d. %%(title)s.%%(ext)s" 
))
IF NOT DEFINED stop_on_error (
SET      Options=%DEBUG% --ignore-errors --ignore-config --js-runtimes "%JS_RUNTIME_NAME%:%JS_RUNTIME_PATH%" --extractor-args "youtube:%EXTRACTOR_ARGS%"
) ELSE (IF "%stop_on_error%"=="9" (
SET      Options=%DEBUG% --ignore-config --js-runtimes "%JS_RUNTIME_NAME%:%JS_RUNTIME_PATH%" --extractor-args "youtube:%EXTRACTOR_ARGS%"
) ELSE (
SET      Options=%DEBUG% --ignore-errors --ignore-config --js-runtimes "%JS_RUNTIME_NAME%:%JS_RUNTIME_PATH%" --extractor-args "youtube:%EXTRACTOR_ARGS%" --skip-playlist-after-errors %stop_on_error%
))
IF NOT DEFINED proxy (
SET      Network= --add-headers "User-Agent:%USER_AGENT%"
) ELSE (IF "%proxy-option%"=="1" (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "http://%proxy_address%"
) ELSE (IF "%proxy-option%"=="2" (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "http://%proxy_username%:%proxy_password%@%proxy_address%"
) ELSE (IF "%proxy-option%"=="3" (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "socks5://%proxy_address%"
) ELSE (IF "%proxy-option%"=="4" (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "socks5://%proxy_username%:%proxy_password%@%proxy_address%"
) ELSE (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "%PROXY%"
)))))
IF NOT DEFINED geo-bypass (
SET  GeoRestrict=
) ELSE (IF "%geo-option%"=="1" (
SET  GeoRestrict= --xff "%GEO-BYPASS%"
) ELSE (IF "%geo-option%"=="2" (
SET  GeoRestrict= --xff "%geo_iso_code%"
) ELSE (IF "%geo-option%"=="3" (
SET  GeoRestrict= --xff "%geo_cidr%"
) ELSE (IF "%geo-option%"=="4" (
SET  GeoRestrict= --geo-verification-proxy "http://%geo_proxy_address%"
) ELSE (IF "%geo-option%"=="5" (
SET  GeoRestrict= --geo-verification-proxy "http://%geo_proxy_username%:%geo_proxy_password%@%geo_proxy_address%"
) ELSE (IF "%geo-option%"=="6" (
SET  GeoRestrict= --geo-verification-proxy "socks5://%geo_proxy_address%"
) ELSE (IF "%geo-option%"=="7" (
SET  GeoRestrict= --geo-verification-proxy "socks5://%geo_proxy_username%:%geo_proxy_password%@%geo_proxy_address%"
) ELSE (
SET  GeoRestrict= --xff "%GEO-BYPASS%"
))))))))
IF "%OnlyNew%"=="1" (
SET       Select= --download-archive "%ARCHIVE_PATH%" --yes-playlist --no-playlist-reverse --compat-options no-youtube-unavailable-videos
) ELSE (
SET       Select= --no-download-archive --yes-playlist --no-playlist-reverse --compat-options no-youtube-unavailable-videos
)
IF DEFINED USEARIA (
SET     Download= --downloader "%ARIA2_PATH%" --downloader-args "aria2c: %ARIA_ARGS%" --compat-options no-external-downloader-progress
) ELSE (
SET     Download= --limit-rate %SPEED_LIMIT% --retries %RETRIES% --fragment-retries %FRAGMENT_RETRIES% --buffer-size %BUFFER_SIZE% --concurrent-fragments %THREADS%
)
SET Sponsorblock= --sponsorblock-remove %SPONSORBLOCK_OPT%
SET   FileSystem= --cache-dir "%YTDLP_CACHE_DIR%" --no-mtime --ffmpeg-location "%FFMPEG_PATH%"
IF "%CropThumb%"=="1" (
SET    Thumbnail= --embed-thumbnail --convert-thumbnail %THUMB_FORMAT% --postprocessor-args "Merger+ffmpeg_o: -c:v %FFMPEG_THUMB_FORMAT% -q:v %THUMB_COMPRESS% -vf \"crop=%CROP%\""
) ELSE (
SET    Thumbnail= --embed-thumbnail --convert-thumbnail %THUMB_FORMAT% --postprocessor-args "ThumbnailsConvertor:-q:v %THUMB_COMPRESS%"
)
SET    Verbosity= --color always --console-title --progress --progress-template ["download] [Progress":" %%(progress._percent_str)s, Speed: %%(progress._speed_str)s, Elapsed: %%(progress._elapsed_str)s, Time Remaining: %%(progress._eta_str|0)s/s"]
IF NOT DEFINED reasonable-timeouts (IF "%use_pl_returnyoutubedislike%"=="1" (
SET  WorkArounds= --use-postprocessor "ReturnYoutubeDislike:when=pre_process"
) ELSE (
SET  WorkArounds=
)) ELSE (IF "%use_pl_returnyoutubedislike%"=="1" (
SET  WorkArounds= %SLEEP% --use-postprocessor "ReturnYoutubeDislike:when=pre_process"
) ELSE (
SET  WorkArounds= %SLEEP%
))
IF "%CustomFormatVideo%"=="1" (
SET       Format= --format "bv*+ba/b" --merge-output-format mkv
) ELSE (IF "%CustomFormatVideo%"=="2" (
SET       Format= -S "+size,+br,+res,+fps" --merge-output-format mkv
) ELSE (IF "%CustomFormatVideo%"=="3" (
SET       Format= -S "+size,+br" --merge-output-format mkv
) ELSE (IF "%CustomCodec%"=="avc" (
SET       Format= --format "(bestvideo*[vcodec~='^((he|a)vc|h26[45])'][height<=%VideoResolution%][fps<=%VideoFPS%]/bestvideo[ext=mp4]) + (bestaudio[acodec=opus][format_note*=original]/bestaudio[acodec~='^(mp?4a|aac)'][format_note*=original]/bestaudio[container*=dash]) / (bestvideo*[height<=%VideoResolution%][fps<=%VideoFPS%]+ba/b)" --merge-output-format mp4 --postprocessor-args "Merger:-v quiet -y -threads 0 -vcodec copy -b:a %AUDIO_BITRATE%k -ar %AUDIO_SAMPLING_RATE% -acodec %ENCODER% -cutoff %CUTOFF%"
) ELSE (IF "%CustomCodec%"=="vp9" (
SET       Format= --format "(bestvideo*[vcodec~='^(vp9.2|vp09|vp9)'][height<=%VideoResolution%][fps<=%VideoFPS%]/bestvideo*[height<=%VideoResolution%][fps<=%VideoFPS%]/bestvideo)+(bestaudio[acodec=opus][format_note*=original]/bestaudio[acodec~='^(mp?4a|aac)'][format_note*=original]/bestaudio[container*=dash])/(bestvideo*[height<=%VideoResolution%][fps<=%VideoFPS%]+ba/b)" --merge-output-format mkv --postprocessor-args "Merger:-v quiet -y -threads 0 -vcodec copy -b:a %AUDIO_BITRATE%k -ar %AUDIO_SAMPLING_RATE% -acodec %ENCODER% -cutoff %CUTOFF%"
) ELSE (IF "%CustomCodec%"=="av1" (
SET       Format= --format "(bestvideo*[vcodec^=av01][height<=%VideoResolution%][fps<=%VideoFPS%]/bestvideo[ext=mp4])+(bestaudio[acodec=opus][format_note*=original]/bestaudio[acodec~='^(mp?4a|aac)'][format_note*=original]/bestaudio[container*=dash]) / (bestvideo*[height<=%VideoResolution%][fps<=%VideoFPS%]+ba/b)" --merge-output-format mp4 --postprocessor-args "Merger:-v quiet -y -threads 0 -vcodec copy -b:a %AUDIO_BITRATE%k -ar %AUDIO_SAMPLING_RATE% -acodec %ENCODER% -cutoff %CUTOFF%"
) ELSE (IF "%CustomCodec%"=="any" (
SET       Format= --format "(bestvideo*[height=?%VideoResolution%][fps=?%VideoFPS%])+(bestaudio[acodec=opus][format_note*=original]/bestaudio[acodec~='^(mp?4a|aac)'][format_note*=original]/bestaudio[container*=dash])/(bestvideo*[height<=?%VideoResolution%][fps<=?%VideoFPS%]+ba/b)" --merge-output-format mkv --postprocessor-args "Merger:-v quiet -y -threads 0 -vcodec copy -b:a %AUDIO_BITRATE%k -ar %AUDIO_SAMPLING_RATE% -acodec %ENCODER% -cutoff %CUTOFF%"
)))))))
SET     Subtitle= --sub-format "%SUB_FORMAT%" --sub-langs "%SUB_LANGS%" --compat-options no-live-chat
IF "%CommentPreset%"=="1" (
SET     Comments= --write-comments --extractor-args "youtube:max_comments=50;comment_sort=top" --exec before_dl:"\"%PYTHON_PATH%\" \"%YTDLP_FOLDER%\yt-dlp_nest_comments_fork.py\" -i %%(infojson_filename)#q -o %%(infojson_filename)#q.comments.html" --exec before_dl:"del /q %%(infojson_filename)#q"
) ELSE (
SET     Comments=
)
IF "%usecookies%"=="1" (
SET Authenticate= --cookies "%COOKIES_PATH%"
) ELSE (
SET Authenticate=
)
IF DEFINED use_pl_yandextranslate (
SET    AdobePass= --use-extractors YandexTranslate --audio-multistreams --extractor-args YandexTranslate:orig_volume=0.3:codec=libopus
) ELSE (
SET    AdobePass=
)
:: --replace-in-metadata meta_album_artist "^.*$" "Various Artists"
IF "%VariousArtists%"=="1" (
SET   PreProcess= --parse-metadata "title:%%(artist)s - %%(title)s" --parse-metadata "title:%%(artist)s — %%(title)s" --parse-metadata "%%(epoch>%%Y-%%m-%%d)s:%%(meta_download_date)s" --parse-metadata "%%(album,playlist_title)s:%%(meta_album)s" --parse-metadata "%%(album_artist|Various Artists)s:%%(meta_album_artist)s" --parse-metadata "%%(average_rating)s:%%(meta_rating)s" --parse-metadata "%%(composer,composers)s:%%(meta_composer)s" --parse-metadata "%%(disc_number)s:%%(meta_disc)s" --parse-metadata "%%(dislike_count)s:%%(meta_dislikes)s" --parse-metadata "%%(genre,genres)s:%%(meta_genre)s" --parse-metadata "%%(like_count)s:%%(meta_likes)s" --parse-metadata "%%(playlist_index,track_number,playlist_autonumber|01)02d:%%(meta_track)s" --parse-metadata "%%(release_date>%%Y-%%m-%%d,release_year,upload_date>%%Y-%%m-%%d)s:%%(meta_date)s" --parse-metadata "%%(view_count)s:%%(meta_views)s" --parse-metadata "description:(?s)(?P<meta_comment>.+)" --parse-metadata ":(?P<meta_description>)" --parse-metadata ":(?P<meta_longdescription>)" --parse-metadata ":(?P<meta_synopsis>)" --parse-metadata ":(?P<meta_purl>)" --parse-metadata "webpage_url:%%(meta_www)s" --replace-in-metadata meta_album_artist " - Topic" "" --replace-in-metadata meta_date "^NA$" "" --replace-in-metadata meta_rating "^NA$" "" --replace-in-metadata meta_views "^NA$" "" --replace-in-metadata meta_likes "^NA$" "" --replace-in-metadata meta_dislikes "^NA$" "" --replace-in-metadata meta_disc "^NA$" "" --replace-in-metadata meta_composer "^NA$" "" --replace-in-metadata meta_album "^NA$" "" --replace-in-metadata meta_genre "^NA$" "" --replace-in-metadata title "/" "⁄" --replace-in-metadata title ":" "꞉" --replace-in-metadata album "/" "⁄" --replace-in-metadata album ":" "꞉"
) ELSE (
SET   PreProcess= --parse-metadata "%%(epoch>%%Y-%%m-%%d)s:%%(meta_download_date)s" --parse-metadata "%%(album,playlist_title)s:%%(meta_album)s" --parse-metadata "%%(album_artist,album_artists,uploader)s:%%(meta_album_artist)s" --parse-metadata "%%(artist,artists.0,creator,uploader)s:%%(meta_artist)s" --parse-metadata "%%(average_rating)s:%%(meta_rating)s" --parse-metadata "%%(composer,composers)s:%%(meta_composer)s" --parse-metadata "%%(disc_number)s:%%(meta_disc)s" --parse-metadata "%%(dislike_count)s:%%(meta_dislikes)s" --parse-metadata "%%(genre,genres)s:%%(meta_genre)s" --parse-metadata "%%(like_count)s:%%(meta_likes)s" --parse-metadata "%%(playlist_index,track_number,playlist_autonumber|01)02d:%%(meta_track)s" --parse-metadata "%%(release_date>%%Y-%%m-%%d,release_year,upload_date>%%Y-%%m-%%d)s:%%(meta_date)s" --parse-metadata "%%(view_count)s:%%(meta_views)s" --parse-metadata "description:(?s)(?P<meta_comment>.+)" --parse-metadata ":(?P<meta_description>)" --parse-metadata ":(?P<meta_longdescription>)" --parse-metadata ":(?P<meta_synopsis>)" --parse-metadata ":(?P<meta_purl>)" --parse-metadata "webpage_url:%%(meta_www)s" --replace-in-metadata meta_album_artist " - Topic" "" --replace-in-metadata meta_date "^NA$" "" --replace-in-metadata meta_rating "^NA$" "" --replace-in-metadata meta_views "^NA$" "" --replace-in-metadata meta_likes "^NA$" "" --replace-in-metadata meta_dislikes "^NA$" "" --replace-in-metadata meta_disc "^NA$" "" --replace-in-metadata meta_composer "^NA$" "" --replace-in-metadata meta_album "^NA$" "" --replace-in-metadata meta_genre "^NA$" "" --replace-in-metadata title "/" "⁄" --replace-in-metadata title ":" "꞉" --replace-in-metadata album "/" "⁄" --replace-in-metadata album ":" "꞉"
)
SET  PostProcess= --embed-metadata --embed-chapters --embed-subs --compat-options no-attach-info-json
SET   ReplayGain=
IF NOT DEFINED duration_filter (
SET     Duration=
) ELSE (IF "%duration_filter%"=="1" (
SET     Duration= --match-filters "^^^!is_live&duration%duration_filter_1%"
) ELSE (IF "%duration_filter%"=="2" (
SET     Duration= --match-filters "^^^!is_live&duration%duration_filter_1%&duration%duration_filter_2%"
) ELSE (IF "%duration_filter%"=="3" (
SET     Duration= --match-filters "^^^!is_live&duration%duration_filter_1%&duration%duration_filter_2%&duration%duration_filter_3%"
) ELSE (IF "%duration_filter%"=="4" (
SET     Duration= --match-filters "^^^!is_live&duration%duration_filter_1%&duration%duration_filter_2%&duration%duration_filter_3%&duration%duration_filter_4%"
) ELSE (IF "%duration_filter%"=="5" (
SET     Duration= --match-filters "is_live&duration%duration_filter_1%"
) ELSE (IF "%duration_filter%"=="6" (
SET     Duration= --match-filters "is_live&duration%duration_filter_1%&duration%duration_filter_2%"
) ELSE (IF "%duration_filter%"=="7" (
SET     Duration= --match-filters "is_live&duration%duration_filter_1%&duration%duration_filter_2%&duration%duration_filter_3%"
) ELSE (IF "%duration_filter%"=="8" (
SET     Duration= --match-filters "is_live&duration%duration_filter_1%&duration%duration_filter_2%&duration%duration_filter_3%&duration%duration_filter_4%"
) ELSE (IF "%duration_filter%"=="9" (
SET     Duration= --match-filters "duration<60"
) ELSE (IF "%duration_filter%"=="10" (
SET     Duration= --match-filters "duration>60"
) ELSE (IF "%duration_filter%"=="11" (
SET     Duration= --match-filters "duration<600"
) ELSE (IF "%duration_filter%"=="12" (
SET     Duration= --match-filters "duration>600"
) ELSE (IF "%duration_filter%"=="13" (
SET     Duration= --match-filters "duration>=60&duration<=600"
) ELSE (IF "%duration_filter%"=="14" (
SET     Duration= --match-filters "is_live"
) ELSE (IF "%duration_filter%"=="15" (
SET     Duration= --match-filters "^^^!is_live"
))))))))))))))))
IF NOT DEFINED date_filter (
SET  Date_Filter=
) ELSE (IF "%date_filter%"=="1" (
SET  Date_Filter= --break-match-filters "upload_date <= %date_filter_1%"
) ELSE (IF "%date_filter%"=="2" (
SET  Date_Filter= --break-match-filters "upload_date >= %date_filter_1%"
) ELSE (IF "%date_filter%"=="3" (
SET  Date_Filter= --break-match-filters "upload_date <= %date_filter_1%&upload_date >= %date_filter_2%"
) ELSE (IF "%date_filter%"=="4" (
SET  Date_Filter= --break-match-filters "upload_date == %date_filter_1%"
) ELSE (IF "%date_filter%"=="5" (
SET  Date_Filter= --break-match-filters "upload_date <= %date_filter_1%&duration%duration_filter_1%"
) ELSE (IF "%date_filter%"=="6" (
SET  Date_Filter= --break-match-filters "upload_date >= %date_filter_1%&duration%duration_filter_1%"
) ELSE (IF "%date_filter%"=="7" (
SET  Date_Filter= --break-match-filters "upload_date <= %date_filter_1%&upload_date >= %date_filter_2%&duration%duration_filter_1%"
) ELSE (IF "%date_filter%"=="8" (
SET  Date_Filter= --break-match-filters "upload_date == %date_filter_1%&duration%duration_filter_1%"
) ELSE (IF "%date_filter%"=="9" (
SET  Date_Filter= --break-match-filters "upload_date <= %date_filter_1%&duration%duration_filter_1%&duration%duration_filter_2%"
) ELSE (IF "%date_filter%"=="10" (
SET  Date_Filter= --break-match-filters "upload_date >= %date_filter_1%&duration%duration_filter_1%&duration%duration_filter_2%"
) ELSE (IF "%date_filter%"=="11" (
SET  Date_Filter= --break-match-filters "upload_date <= %date_filter_1%&upload_date >= %date_filter_2%&duration%duration_filter_1%&duration%duration_filter_2%"
) ELSE (IF "%date_filter%"=="12" (
SET  Date_Filter= --break-match-filters "upload_date == %date_filter_1%&duration%duration_filter_1%&duration%duration_filter_2%"
)))))))))))))
:: setting variables for continue menu
SET Downloaded-Video=1& SET Downloaded-Audio=& SET Downloaded-Manual=& SET Downloaded-Manual-Single=& SET Downloaded-Comments=& SET Downloaded-Subs=& SET Downloaded-Sections=& SET Downloaded-Stream=& SET Downloaded-Quick=& GOTO :doYTDL-check

::
::
:: SUBTITLES AND COMMENTS PRESETS
::
::

:: DOWNLOAD JUST SUBS
:subs-preset-1
IF "%SubsPreset%"=="1" (
SET  OutTemplate= --output "%TARGET_FOLDER%\%%(title)s.%%(ext)s"
) ELSE (IF "%SubsPreset%"=="2" (
SET  OutTemplate= --output "%TARGET_FOLDER%\%%(title)s-transcript.%%(ext)s"
))
IF NOT DEFINED stop_on_error (
SET      Options=%DEBUG% --ignore-errors --ignore-config --js-runtimes "%JS_RUNTIME_NAME%:%JS_RUNTIME_PATH%" --extractor-args "youtube:%EXTRACTOR_ARGS%"
) ELSE (IF "%stop_on_error%"=="9" (
SET      Options=%DEBUG% --ignore-config --js-runtimes "%JS_RUNTIME_NAME%:%JS_RUNTIME_PATH%" --extractor-args "youtube:%EXTRACTOR_ARGS%"
) ELSE (
SET      Options=%DEBUG% --ignore-errors --ignore-config --js-runtimes "%JS_RUNTIME_NAME%:%JS_RUNTIME_PATH%" --extractor-args "youtube:%EXTRACTOR_ARGS%" --skip-playlist-after-errors %stop_on_error%
))
IF NOT DEFINED proxy (
SET      Network= --add-headers "User-Agent:%USER_AGENT%"
) ELSE (IF "%proxy-option%"=="1" (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "http://%proxy_address%"
) ELSE (IF "%proxy-option%"=="2" (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "http://%proxy_username%:%proxy_password%@%proxy_address%"
) ELSE (IF "%proxy-option%"=="3" (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "socks5://%proxy_address%"
) ELSE (IF "%proxy-option%"=="4" (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "socks5://%proxy_username%:%proxy_password%@%proxy_address%"
) ELSE (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "%PROXY%"
)))))
IF NOT DEFINED geo-bypass (
SET  GeoRestrict=
) ELSE (IF "%geo-option%"=="1" (
SET  GeoRestrict= --xff "%GEO-BYPASS%"
) ELSE (IF "%geo-option%"=="2" (
SET  GeoRestrict= --xff "%geo_iso_code%"
) ELSE (IF "%geo-option%"=="3" (
SET  GeoRestrict= --xff "%geo_cidr%"
) ELSE (IF "%geo-option%"=="4" (
SET  GeoRestrict= --geo-verification-proxy "http://%geo_proxy_address%"
) ELSE (IF "%geo-option%"=="5" (
SET  GeoRestrict= --geo-verification-proxy "http://%geo_proxy_username%:%geo_proxy_password%@%geo_proxy_address%"
) ELSE (IF "%geo-option%"=="6" (
SET  GeoRestrict= --geo-verification-proxy "socks5://%geo_proxy_address%"
) ELSE (IF "%geo-option%"=="7" (
SET  GeoRestrict= --geo-verification-proxy "socks5://%geo_proxy_username%:%geo_proxy_password%@%geo_proxy_address%"
) ELSE (
SET  GeoRestrict= --xff "%GEO-BYPASS%"
))))))))
SET       Select=
SET     Download= --skip-download --concurrent-fragments 1
SET Sponsorblock=
SET   FileSystem= --cache-dir "%YTDLP_CACHE_DIR%" --ffmpeg-location "%FFMPEG_PATH%"
SET    Thumbnail=
SET    Verbosity= --color always --console-title --progress --progress-template ["download] [Progress":" %%(progress._percent_str)s, Speed: %%(progress._speed_str)s, Elapsed: %%(progress._elapsed_str)s, Time Remaining: %%(progress._eta_str|0)s/s"]
IF NOT DEFINED reasonable-timeouts (
SET  WorkArounds= --sleep-subtitles 60
) ELSE (
SET  WorkArounds= %SLEEP% -sleep-subtitles 60
)
SET       Format=
IF "%SubsPreset%"=="1" (
SET     Subtitle= --write-subs --write-auto-subs --sub-format "%SUB_FORMAT%" --sub-langs "%SUB_LANGS%" --compat-options no-live-chat
) ELSE (IF "%SubsPreset%"=="2" (
SET     Subtitle= --write-subs --write-auto-subs --sub-format ttml --convert-subs srt --sub-langs "%SUB_LANGS%" --compat-options no-live-chat
) ELSE (IF "%SubsPreset%"=="3" (
SET     Subtitle= --sub-langs "%SUB_LANGS%" --write-auto-subs --write-subs --convert-subs srt --use-postprocessor srt_fix:when=before_dl --compat-options no-live-chat
)))
SET     Comments=
IF "%usecookies%"=="1" (
SET Authenticate= --cookies "%COOKIES_PATH%"
) ELSE (
SET Authenticate=
)
IF "%SubsPreset%"=="2" (
SET    AdobePass= --exec before_dl:"\"%SED_PATH%\" -i -f \"%SED_COMMANDS%\" %%(requested_subtitles.:.filepath)#q"
) ELSE (
SET    AdobePass= 
)
SET   PreProcess=
SET  PostProcess=
:: setting variables for continue menu
SET Downloaded-Video=& SET Downloaded-Audio=& SET Downloaded-Manual=& SET Downloaded-Manual-Single=& SET Downloaded-Comments=& SET Downloaded-Subs=1& SET Downloaded-Sections=& SET Downloaded-Stream=& SET Downloaded-Quick=& GOTO :doYTDL-check

:: DOWNLOAD JUST COMMENTS
:comments-preset-1
SET  OutTemplate= --output "%TARGET_FOLDER%\%%(title)s.%%(ext)s"
IF NOT DEFINED stop_on_error (
SET      Options=%DEBUG% --ignore-errors --ignore-config --js-runtimes "%JS_RUNTIME_NAME%:%JS_RUNTIME_PATH%" --extractor-args "youtube:%EXTRACTOR_ARGS%"
) ELSE (IF "%stop_on_error%"=="9" (
SET      Options=%DEBUG% --ignore-config --js-runtimes "%JS_RUNTIME_NAME%:%JS_RUNTIME_PATH%" --extractor-args "youtube:%EXTRACTOR_ARGS%"
) ELSE (
SET      Options=%DEBUG% --ignore-errors --ignore-config --js-runtimes "%JS_RUNTIME_NAME%:%JS_RUNTIME_PATH%" --extractor-args "youtube:%EXTRACTOR_ARGS%" --skip-playlist-after-errors %stop_on_error%
))
IF NOT DEFINED proxy (
SET      Network= --add-headers "User-Agent:%USER_AGENT%"
) ELSE (IF "%proxy-option%"=="1" (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "http://%proxy_address%"
) ELSE (IF "%proxy-option%"=="2" (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "http://%proxy_username%:%proxy_password%@%proxy_address%"
) ELSE (IF "%proxy-option%"=="3" (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "socks5://%proxy_address%"
) ELSE (IF "%proxy-option%"=="4" (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "socks5://%proxy_username%:%proxy_password%@%proxy_address%"
) ELSE (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "%PROXY%"
)))))
IF NOT DEFINED geo-bypass (
SET  GeoRestrict=
) ELSE (IF "%geo-option%"=="1" (
SET  GeoRestrict= --xff "%GEO-BYPASS%"
) ELSE (IF "%geo-option%"=="2" (
SET  GeoRestrict= --xff "%geo_iso_code%"
) ELSE (IF "%geo-option%"=="3" (
SET  GeoRestrict= --xff "%geo_cidr%"
) ELSE (IF "%geo-option%"=="4" (
SET  GeoRestrict= --geo-verification-proxy "http://%geo_proxy_address%"
) ELSE (IF "%geo-option%"=="5" (
SET  GeoRestrict= --geo-verification-proxy "http://%geo_proxy_username%:%geo_proxy_password%@%geo_proxy_address%"
) ELSE (IF "%geo-option%"=="6" (
SET  GeoRestrict= --geo-verification-proxy "socks5://%geo_proxy_address%"
) ELSE (IF "%geo-option%"=="7" (
SET  GeoRestrict= --geo-verification-proxy "socks5://%geo_proxy_username%:%geo_proxy_password%@%geo_proxy_address%"
) ELSE (
SET  GeoRestrict= --xff "%GEO-BYPASS%"
))))))))
SET       Select=
SET     Download= --skip-download
SET Sponsorblock=
SET   FileSystem= --cache-dir "%YTDLP_CACHE_DIR%" --ffmpeg-location "%FFMPEG_PATH%"
SET    Thumbnail=
SET    Verbosity= --color always --console-title --progress --progress-template ["download] [Progress":" %%(progress._percent_str)s, Speed: %%(progress._speed_str)s, Elapsed: %%(progress._elapsed_str)s, Time Remaining: %%(progress._eta_str|0)s/s"]
IF NOT DEFINED reasonable-timeouts (
SET  WorkArounds=
) ELSE (
SET  WorkArounds= %SLEEP%
)
SET       Format=
SET     Subtitle=
IF "%CommentPreset%"=="1" (
SET     Comments= --write-comments --extractor-args "youtube:max_comments=25;comment_sort=top" --print-to-file "%%(comments)j" "%%(title)s.comments.json"
) ELSE (IF "%CommentPreset%"=="2" (
SET     Comments= --write-comments --extractor-args "youtube:max_comments=25;comment_sort=top"
) ELSE (IF "%CommentPreset%"=="3" (
SET     Comments= --write-comments --extractor-args "youtube:max_comments=500,all,all,50;comment_sort=top" --print-to-file "%%(comments)j" "%%(title)s.comments.json"
) ELSE (IF "%CommentPreset%"=="4" (
SET     Comments= --write-comments --extractor-args "youtube:max_comments=500,all,all,50;comment_sort=top"
) ELSE (IF "%CommentPreset%"=="5" (
SET     Comments= --write-comments --extractor-args "youtube:max_comments=all,all,all,all;comment_sort=top" --print-to-file "%%(comments)j" "%%(title)s.comments.json"
) ELSE (IF "%CommentPreset%"=="6" (
SET     Comments= --write-comments --extractor-args "youtube:max_comments=all,all,all,all;comment_sort=top"
) ELSE (IF "%CommentPreset%"=="7" (
SET     Comments= --write-comments --extractor-args "youtube:max_comments=25;comment_sort=new" --print-to-file "%%(comments)j" "%%(title)s.comments.json"
) ELSE (IF "%CommentPreset%"=="8" (
SET     Comments= --write-comments --extractor-args "youtube:max_comments=25;comment_sort=new"
) ELSE (IF "%CommentPreset%"=="9" (
SET     Comments= --write-comments --extractor-args "youtube:max_comments=500,all,all,50;comment_sort=new" --print-to-file "%%(comments)j" "%%(title)s.comments.json"
) ELSE (IF "%CommentPreset%"=="10" (
SET     Comments= --write-comments --extractor-args "youtube:max_comments=500,all,all,50;comment_sort=new"
) ELSE (IF "%CommentPreset%"=="11" (
SET     Comments= --write-comments --extractor-args "youtube:max_comments=all,all,all,all;comment_sort=new" --print-to-file "%%(comments)j" "%%(title)s.comments.json"
) ELSE (IF "%CommentPreset%"=="12" (
SET     Comments= --write-comments --extractor-args "youtube:max_comments=all,all,all,all;comment_sort=new"
) ELSE (IF "%CommentPreset%"=="13" (
SET     Comments= --write-comments --extractor-args "youtube:max_comments=500,all,all,50;comment_sort=new"
)))))))))))))
IF "%usecookies%"=="1" (
SET Authenticate= --cookies "%COOKIES_PATH%"
) ELSE (
SET Authenticate=
)
IF "%CommentPreset%"=="1" (
SET    AdobePass= --exec pre_process:"del /q %%(id)s.comments.json"
) ELSE (IF "%CommentPreset%"=="2" (
SET    AdobePass= --exec before_dl:"\"%PYTHON_PATH%\" \"%YTDLP_FOLDER%\yt-dlp_nest_comments_fork.py\" -i %%(infojson_filename)#q -o %%(infojson_filename)#q.comments.html" --exec before_dl:"del /q %%(infojson_filename)#q"
) ELSE (IF "%CommentPreset%"=="3" (
SET    AdobePass= --exec pre_process:"del /q %%(id)s.comments.json"
) ELSE (IF "%CommentPreset%"=="4" (
SET    AdobePass= --exec before_dl:"\"%PYTHON_PATH%\" \"%YTDLP_FOLDER%\yt-dlp_nest_comments_fork.py\" -i %%(infojson_filename)#q -o %%(infojson_filename)#q.comments.html" --exec before_dl:"del /q %%(infojson_filename)#q"
) ELSE (IF "%CommentPreset%"=="5" (
SET    AdobePass= --exec pre_process:"del /q %%(id)s.comments.json"
) ELSE (IF "%CommentPreset%"=="6" (
SET    AdobePass= --exec before_dl:"\"%PYTHON_PATH%\" \"%YTDLP_FOLDER%\yt-dlp_nest_comments_fork.py\" -i %%(infojson_filename)#q -o %%(infojson_filename)#q.comments.html" --exec before_dl:"del /q %%(infojson_filename)#q"
) ELSE (IF "%CommentPreset%"=="7" (
SET    AdobePass= --exec pre_process:"del /q %%(id)s.comments.json"
) ELSE (IF "%CommentPreset%"=="8" (
SET    AdobePass= --exec before_dl:"\"%PYTHON_PATH%\" \"%YTDLP_FOLDER%\yt-dlp_nest_comments_fork.py\" -i %%(infojson_filename)#q -o %%(infojson_filename)#q.comments.html" --exec before_dl:"del /q %%(infojson_filename)#q"
) ELSE (IF "%CommentPreset%"=="9" (
SET    AdobePass= --exec pre_process:"del /q %%(id)s.comments.json"
) ELSE (IF "%CommentPreset%"=="10" (
SET    AdobePass= --exec before_dl:"\"%PYTHON_PATH%\" \"%YTDLP_FOLDER%\yt-dlp_nest_comments_fork.py\" -i %%(infojson_filename)#q -o %%(infojson_filename)#q.comments.html" --exec before_dl:"del /q %%(infojson_filename)#q"
) ELSE (IF "%CommentPreset%"=="11" (
SET    AdobePass= --exec pre_process:"del /q %%(id)s.comments.json"
) ELSE (IF "%CommentPreset%"=="12" (
SET    AdobePass= --exec before_dl:"\"%PYTHON_PATH%\" \"%YTDLP_FOLDER%\yt-dlp_nest_comments_fork.py\" -i %%(infojson_filename)#q -o %%(infojson_filename)#q.comments.html" --exec before_dl:"del /q %%(infojson_filename)#q"
) ELSE (IF "%CommentPreset%"=="13" (
SET    AdobePass= --exec before_dl:"\"%PYTHON_PATH%\" \"%YTDLP_FOLDER%\yt-dlp_nest_comments_new.py\" -i %%(infojson_filename)#q -o %%(infojson_filename)#q.comments.html" --exec before_dl:"del /q %%(infojson_filename)#q"
)))))))))))))
SET   PreProcess=
SET  PostProcess=
:: setting variables for continue menu
SET Downloaded-Video=& SET Downloaded-Audio=& SET Downloaded-Manual=& SET Downloaded-Manual-Single=& SET Downloaded-Comments=1& SET Downloaded-Subs=& SET Downloaded-Sections=& SET Downloaded-Stream=& SET Downloaded-Quick=& GOTO :doYTDL-check

::
::
:: STREAM TO PLAYER PRESETS
::
::

:: STREAM TO PLAYER
:doYTDL-preset-stream-1
SET  OutTemplate= --output -
IF NOT DEFINED stop_on_error (
SET      Options=%DEBUG% --ignore-errors --ignore-config --js-runtimes "%JS_RUNTIME_NAME%:%JS_RUNTIME_PATH%" --extractor-args "youtube:%EXTRACTOR_ARGS%"
) ELSE (IF "%stop_on_error%"=="9" (
SET      Options=%DEBUG% --ignore-config --js-runtimes "%JS_RUNTIME_NAME%:%JS_RUNTIME_PATH%" --extractor-args "youtube:%EXTRACTOR_ARGS%"
) ELSE (
SET      Options=%DEBUG% --ignore-errors --ignore-config --js-runtimes "%JS_RUNTIME_NAME%:%JS_RUNTIME_PATH%" --extractor-args "youtube:%EXTRACTOR_ARGS%" --skip-playlist-after-errors %stop_on_error%
))
IF NOT DEFINED proxy (
SET      Network= --add-headers "User-Agent:%USER_AGENT%"
) ELSE (IF "%proxy-option%"=="1" (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "http://%proxy_address%"
) ELSE (IF "%proxy-option%"=="2" (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "http://%proxy_username%:%proxy_password%@%proxy_address%"
) ELSE (IF "%proxy-option%"=="3" (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "socks5://%proxy_address%"
) ELSE (IF "%proxy-option%"=="4" (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "socks5://%proxy_username%:%proxy_password%@%proxy_address%"
) ELSE (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "%PROXY%"
)))))
IF NOT DEFINED geo-bypass (
SET  GeoRestrict=
) ELSE (IF "%geo-option%"=="1" (
SET  GeoRestrict= --xff "%GEO-BYPASS%"
) ELSE (IF "%geo-option%"=="2" (
SET  GeoRestrict= --xff "%geo_iso_code%"
) ELSE (IF "%geo-option%"=="3" (
SET  GeoRestrict= --xff "%geo_cidr%"
) ELSE (IF "%geo-option%"=="4" (
SET  GeoRestrict= --geo-verification-proxy "http://%geo_proxy_address%"
) ELSE (IF "%geo-option%"=="5" (
SET  GeoRestrict= --geo-verification-proxy "http://%geo_proxy_username%:%geo_proxy_password%@%geo_proxy_address%"
) ELSE (IF "%geo-option%"=="6" (
SET  GeoRestrict= --geo-verification-proxy "socks5://%geo_proxy_address%"
) ELSE (IF "%geo-option%"=="7" (
SET  GeoRestrict= --geo-verification-proxy "socks5://%geo_proxy_username%:%geo_proxy_password%@%geo_proxy_address%"
) ELSE (
SET  GeoRestrict= --xff "%GEO-BYPASS%"
))))))))
SET       Select=
SET     Download= --limit-rate %SPEED_LIMIT% --retries %RETRIES% --fragment-retries %FRAGMENT_RETRIES% --buffer-size %BUFFER_SIZE% --concurrent-fragments %THREADS% --downloader "%FFMPEG_PATH%"
SET Sponsorblock=
SET   FileSystem= --cache-dir "%YTDLP_CACHE_DIR%" --ffmpeg-location "%FFMPEG_PATH%"
SET    Thumbnail=
SET    Verbosity= --color always --quiet --console-title --progress
IF NOT DEFINED reasonable-timeouts (
SET  WorkArounds=
) ELSE (
SET  WorkArounds= %SLEEP%
)
IF "%StreamVideoFormat%"=="1" (
SET       Format= --format "((bv[width>1920][height>1080]/bv[width>1080][height>1920]/bv[fps>30])+ba)[protocol^=https] / ((bv[vcodec*=avc])+ba)[protocol^=m3u8] / b*"
) ELSE (IF "%StreamVideoFormat%"=="2" (
SET       Format= --format "bv*[vcodec^=av01][proto=https]+ba[proto=https]/bv*[vcodec^=vp9]+ba[proto=https]/bv*[vcodec^=avc][protocol=m3u8_native]+ba[vcodec^=mp4a][protocol=m3u8_native]"
) ELSE (IF "%StreamVideoFormat%"=="3" (
SET       Format= --format "bv*+ba/b"
) ELSE (IF "%StreamVideoFormat%"=="4" (
SET       Format= -S "+size,+br,+res,+fps"
) ELSE (IF "%StreamVideoFormat%"=="5" (
SET       Format= -S "+size,+br"
) ELSE (IF "%StreamVideoFormat%"=="6" (
SET       Format= --format "(bestvideo*[height=?%VideoResolution%][fps=?%VideoFPS%])+(bestaudio[acodec=opus][format_note*=original]/bestaudio[acodec~='^(mp?4a|aac)'][format_note*=original]/bestaudio[container*=dash])/(bestvideo*[height<=?%VideoResolution%][fps<=?%VideoFPS%]+ba/b)"
) ELSE (IF "%StreamVideoFormat%"=="7" (
SET       Format= --format "(bestvideo*[vcodec~='^((he|a)vc|h26[45])'][height<=%VideoResolution%][fps<=%VideoFPS%]/bestvideo[ext=mp4]) + (bestaudio[acodec=opus][format_note*=original]/bestaudio[acodec~='^(mp?4a|aac)'][format_note*=original]/bestaudio[container*=dash]) / (bestvideo*[height<=%VideoResolution%][fps<=%VideoFPS%]+ba/b)"
) ELSE (IF "%StreamVideoFormat%"=="8" (
SET       Format= --format "(bestvideo*[vcodec~='^(vp9.2|vp09|vp9)'][height<=%VideoResolution%][fps<=%VideoFPS%]/bestvideo*[height<=%VideoResolution%][fps<=%VideoFPS%]/bestvideo)+(bestaudio[acodec=opus][format_note*=original]/bestaudio[acodec~='^(mp?4a|aac)'][format_note*=original]/bestaudio[container*=dash])/(bestvideo*[height<=%VideoResolution%][fps<=%VideoFPS%]+ba/b)"
) ELSE (IF "%StreamVideoFormat%"=="9" (
SET       Format= --format "(bestvideo*[vcodec^=av01][height<=%VideoResolution%][fps<=%VideoFPS%]/bestvideo[ext=mp4])+(bestaudio[acodec=opus][format_note*=original]/bestaudio[acodec~='^(mp?4a|aac)'][format_note*=original]/bestaudio[container*=dash]) / (bestvideo*[height<=%VideoResolution%][fps<=%VideoFPS%]+ba/b)"
) ELSE (IF "%StreamAudioFormat%"=="1" (
SET       Format= --format "ba/b"
) ELSE (IF "%StreamAudioFormat%"=="2" (
SET       Format= --format "ba/b" -S "proto"
)))))))))))
SET     Subtitle=
SET     Comments=
IF "%usecookies%"=="1" (
SET Authenticate= --cookies "%COOKIES_PATH%"
) ELSE (
SET Authenticate=
)
SET    AdobePass=
SET   PreProcess=
SET  PostProcess=
:: setting variables for continue menu
SET Downloaded-Video=& SET Downloaded-Audio=& SET Downloaded-Manual=& SET Downloaded-Manual-Single=& SET Downloaded-Comments=& SET Downloaded-Subs=& SET Downloaded-Sections=& SET Downloaded-Stream=1& SET Downloaded-Quick=& GOTO :doYTDL-stream

::
::
:: DOWNLOAD SECTIONS PRESETS
::
::

:: SECTIONS
:sections-preset-1
SET  OutTemplate= --output "%TARGET_FOLDER%\%%(uploader)s\%%(title)s_%%(section_start)s-%%(section_end)s.%%(ext)s"
IF NOT DEFINED stop_on_error (
SET      Options=%DEBUG% --ignore-errors --ignore-config --js-runtimes "%JS_RUNTIME_NAME%:%JS_RUNTIME_PATH%" --extractor-args "youtube:%EXTRACTOR_ARGS%"
) ELSE (IF "%stop_on_error%"=="9" (
SET      Options=%DEBUG% --ignore-config --js-runtimes "%JS_RUNTIME_NAME%:%JS_RUNTIME_PATH%" --extractor-args "youtube:%EXTRACTOR_ARGS%"
) ELSE (
SET      Options=%DEBUG% --ignore-errors --ignore-config --js-runtimes "%JS_RUNTIME_NAME%:%JS_RUNTIME_PATH%" --extractor-args "youtube:%EXTRACTOR_ARGS%" --skip-playlist-after-errors %stop_on_error%
))
IF NOT DEFINED proxy (
SET      Network= --add-headers "User-Agent:%USER_AGENT%"
) ELSE (IF "%proxy-option%"=="1" (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "http://%proxy_address%"
) ELSE (IF "%proxy-option%"=="2" (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "http://%proxy_username%:%proxy_password%@%proxy_address%"
) ELSE (IF "%proxy-option%"=="3" (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "socks5://%proxy_address%"
) ELSE (IF "%proxy-option%"=="4" (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "socks5://%proxy_username%:%proxy_password%@%proxy_address%"
) ELSE (
SET      Network= --add-headers "User-Agent:%USER_AGENT%" --proxy "%PROXY%"
)))))
IF NOT DEFINED geo-bypass (
SET  GeoRestrict=
) ELSE (IF "%geo-option%"=="1" (
SET  GeoRestrict= --xff "%GEO-BYPASS%"
) ELSE (IF "%geo-option%"=="2" (
SET  GeoRestrict= --xff "%geo_iso_code%"
) ELSE (IF "%geo-option%"=="3" (
SET  GeoRestrict= --xff "%geo_cidr%"
) ELSE (IF "%geo-option%"=="4" (
SET  GeoRestrict= --geo-verification-proxy "http://%geo_proxy_address%"
) ELSE (IF "%geo-option%"=="5" (
SET  GeoRestrict= --geo-verification-proxy "http://%geo_proxy_username%:%geo_proxy_password%@%geo_proxy_address%"
) ELSE (IF "%geo-option%"=="6" (
SET  GeoRestrict= --geo-verification-proxy "socks5://%geo_proxy_address%"
) ELSE (IF "%geo-option%"=="7" (
SET  GeoRestrict= --geo-verification-proxy "socks5://%geo_proxy_username%:%geo_proxy_password%@%geo_proxy_address%"
) ELSE (
SET  GeoRestrict= --xff "%GEO-BYPASS%"
))))))))
IF "%DoSections%"=="1" (
SET       Select= --no-playlist --download-sections "*%section1%"
) ELSE (IF "%DoSections%"=="2" (
SET       Select= --no-playlist --download-sections "*%section1%" --download-sections "*%section2%"
) ELSE (IF "%DoSections%"=="3" (
SET       Select= --no-playlist --download-sections "*%section1%" --download-sections "*%section2%" --download-sections "*%section3%"
) ELSE (IF "%DoSections%"=="4" (
SET       Select= --no-playlist --download-sections "*%section1%" --download-sections "*%section2%" --download-sections "*%section3%" --download-sections "*%section4%"
) ELSE (IF "%DoSections%"=="5" (
SET       Select= --no-playlist --download-sections "*%section1%" --download-sections "*%section2%" --download-sections "*%section3%" --download-sections "*%section4%" --download-sections "*%section5%"
) ELSE (IF "%DoSections%"=="6" (
SET       Select= --no-playlist --download-sections "*%section1%" --download-sections "*%section2%" --download-sections "*%section3%" --download-sections "*%section4%" --download-sections "*%section5%" --download-sections "*%section6%"
) ELSE (IF "%DoSections%"=="7" (
SET       Select= --no-playlist --download-sections "*%section1%" --download-sections "*%section2%" --download-sections "*%section3%" --download-sections "*%section4%" --download-sections "*%section5%" --download-sections "*%section6%" --download-sections "*%section7%"
) ELSE (IF "%DoSections%"=="8" (
SET       Select= --no-playlist --download-sections "*%section1%" --download-sections "*%section2%" --download-sections "*%section3%" --download-sections "*%section4%" --download-sections "*%section5%" --download-sections "*%section6%" --download-sections "*%section7%" --download-sections "*%section8%"
) ELSE (IF "%DoSections%"=="9" (
SET       Select= --no-playlist --download-sections "*%section1%" --download-sections "*%section2%" --download-sections "*%section3%" --download-sections "*%section4%" --download-sections "*%section5%" --download-sections "*%section6%" --download-sections "*%section7%" --download-sections "*%section8%" --download-sections "*%section9%"
) ELSE (IF "%DoSections%"=="10" (
SET       Select= --no-playlist --download-sections "*%section1%" --download-sections "*%section2%" --download-sections "*%section3%" --download-sections "*%section4%" --download-sections "*%section5%" --download-sections "*%section6%" --download-sections "*%section7%" --download-sections "*%section8%" --download-sections "*%section9%" --download-sections "*%section10%"
))))))))))
IF DEFINED USEARIA (
SET     Download= --downloader "%ARIA2_PATH%" --downloader-args "aria2c: %ARIA_ARGS%" --compat-options no-external-downloader-progress
) ELSE (
SET     Download= --limit-rate %SPEED_LIMIT% --retries %RETRIES% --fragment-retries %FRAGMENT_RETRIES% --buffer-size %BUFFER_SIZE% --concurrent-fragments %THREADS%
)
SET Sponsorblock= --no-sponsorblock
SET   FileSystem= --cache-dir "%YTDLP_CACHE_DIR%" --no-mtime --ffmpeg-location "%FFMPEG_PATH%"
IF "%CropThumb%"=="1" (
SET    Thumbnail= --embed-thumbnail --convert-thumbnail %THUMB_FORMAT% --postprocessor-args "ThumbnailsConvertor+ffmpeg_o: -c:v %FFMPEG_THUMB_FORMAT% -q:v %THUMB_COMPRESS% -vf \"crop=%CROP%\""
) ELSE (
SET    Thumbnail= --embed-thumbnail --convert-thumbnail %THUMB_FORMAT% --postprocessor-args "ThumbnailsConvertor:-q:v %THUMB_COMPRESS%"
)
SET    Verbosity= --color always --console-title --progress --progress-template ["download] [Progress":" %%(progress._percent_str)s, Speed: %%(progress._speed_str)s, Elapsed: %%(progress._elapsed_str)s, Time Remaining: %%(progress._eta_str|0)s/s"]
IF NOT DEFINED reasonable-timeouts (IF "%use_pl_returnyoutubedislike%"=="1" (
SET  WorkArounds= --use-postprocessor "ReturnYoutubeDislike:when=pre_process"
) ELSE (
SET  WorkArounds=
)) ELSE (IF "%use_pl_returnyoutubedislike%"=="1" (
SET  WorkArounds= %SLEEP% --use-postprocessor "ReturnYoutubeDislike:when=pre_process"
) ELSE (
SET  WorkArounds= %SLEEP%
))
IF "%CustomFormat-opus%"=="1" (
SET       Format= --extract-audio --format "774/251/250/249" --downloader-args "ffmpeg:-v quiet -vn -y -threads 0 -c:a libopus -b:a %AUDIO_BITRATE%k"
) ELSE (IF "%CustomFormat-m4a%"=="1" (
SET       Format= --extract-audio --format "141/38/22/140/37/59/34/35/59/78/18" "ffmpeg:-v quiet -vn -y -threads 0 -c:a %ENCODER% -b:a %AUDIO_BITRATE%k"
) ELSE (IF "%CustomFormat-ogg%"=="1" (
SET       Format= --extract-audio --format "46/45/44/43" --downloader-args "ffmpeg:-v quiet -vn -y -threads 0 -c:a libvorbis -b:a %AUDIO_BITRATE%k"
) ELSE (IF "%CustomFormat-mp3%"=="1" (
SET       Format= --extract-audio --format "ba[acodec^=mp3]/b" --downloader-args "ffmpeg:-v quiet -vn -y -threads 0 -c:a libmp3lame -b:a %AUDIO_BITRATE%k"
) ELSE (IF "%CustomFormat-m4a%"=="2" (
SET       Format= --extract-audio --format "773/338/258/328/774/327/256/141/251/22/140/38/37/35/34/59/78/18/250/46/45/44/43" --downloader-args "ffmpeg:-v quiet -vn -y -threads 0 -ac 2 -ar %AUDIO_SAMPLING_RATE% -c:a libfdk_aac -vbr %AudioQuality% -cutoff %CUTOFF% -afterburner 1"
) ELSE (IF "%CustomFormat-opus%"=="2" (
SET       Format= --extract-audio --format "338/774/251/250/249" --downloader-args "ffmpeg:-v quiet -vn -y -threads 0 -c:a libopus -b:a %AUDIO_BITRATE%k"
) ELSE (IF "%CustomFormat-m4a%"=="3" (
SET       Format= --extract-audio --format "258/380/327/256/141/38/22/140/37/59/34/35/59/78/18" --downloader-args "ffmpeg:-v quiet -vn -y -threads 0 -c:a %ENCODER% -b:a %AUDIO_BITRATE%k"
) ELSE (IF "%CustomFormat-m4a%"=="4" (
SET       Format= --extract-audio --format "773/338/258/328/774/327/256/141/251/22/140/38/37/35/34/59/78/18/250/46/45/44/43" --audio-format %AudioFormat% --postprocessor-args "ExtractAudio:-v quiet -vn -y -threads 0 -c:a libfdk_aac -vbr %AudioQuality% -cutoff %CUTOFF% -afterburner 1 -af \"%FIREQUALIZER%,%LOUDNORM%,%ARESAMPLE%,%ANLMDN_DENOISING%%COMPAND%,%SILENCEREMOVE%\""
) ELSE (IF "%CustomFormat-opus%"=="3" (
SET       Format= --extract-audio --format "338/774/251/250/249" --downloader-args "ffmpeg:-v quiet -vn -y -threads 0 -c:a libopus -b:a %AUDIO_BITRATE%k -af \"%PAN%,%FIREQUALIZER%,%LOUDNORM%,%ANLMDN_DENOISING%%COMPAND%,%SILENCEREMOVE%\""
) ELSE (IF "%CustomFormat-opus%"=="4" (
SET       Format= --extract-audio --format "bestaudio[acodec^=opus]/bestaudio[container*=dash]/bestaudio" --downloader-args "ffmpeg:-v quiet -vn -y -threads 0 -c:a libopus -b:a %AUDIO_BITRATE%k"
) ELSE (IF "%CustomFormat-m4a%"=="5" (
SET       Format= --format "258/380/327/256/141/38/22/140/37/59/34/35/59/78/18" --audio-format %AudioFormat% --postprocessor-args "ExtractAudio:-v quiet -vn -y -threads 0 -c:a libfdk_aac -vbr %AudioQuality% -cutoff %CUTOFF% -afterburner 1 -af \"%PAN%,%FIREQUALIZER%,%LOUDNORM%,%ARESAMPLE%,%ANLMDN_DENOISING%%COMPAND%,%SILENCEREMOVE%\""
) ELSE (IF "%CustomFormat-m4a%"=="6" (
SET       Format= --extract-audio --format "773/338/258/328/774/327/256/141/251/22/140/38/37/35/34/59/78/18/250/46/45/44/43" --audio-format %AudioFormat% --postprocessor-args "ExtractAudio:-v quiet -y -vn -ac 2 -c:a aac_at %aac-at-param-1% %aac-at-param-2% %aac-at-param-3% %aac-at-param-4% %aac-at-param-5% -cutoff %CUTOFF%"
) ELSE (IF "%CustomFormat-m4a%"=="7" (
SET       Format= --extract-audio --format "773/338/258/328/774/327/256/141/251/22/140/38/37/35/34/59/78/18/250/46/45/44/43" --audio-format %AudioFormat% --postprocessor-args "ExtractAudio:-v quiet -y -vn -ac 2 -c:a aac_at %aac-at-param-1% %aac-at-param-2% %aac-at-param-3% %aac-at-param-4% %aac-at-param-5% -cutoff %CUTOFF% -af \"%FIREQUALIZER%,%LOUDNORM%,%ANLMDN_DENOISING%%COMPAND%,%SILENCEREMOVE%\""
) ELSE (IF "%CustomFormat-m4a%"=="8" (
SET       Format= --extract-audio --format "773/338/258/328/774/327/256/141/251/22/140/38/37/35/34/59/78/18/250/46/45/44/43" --audio-format %AudioFormat% --postprocessor-args "ExtractAudio:-v quiet -y -vn -c:a aac_at %aac-at-param-1% %aac-at-param-2% %aac-at-param-3% %aac-at-param-4% %aac-at-param-5% -cutoff %CUTOFF% -af \"%PAN%,%FIREQUALIZER%,%LOUDNORM%,%ARESAMPLE%,%ANLMDN_DENOISING%%COMPAND%,%SILENCEREMOVE%\""
) ELSE (IF "%BestAudio%"=="1" (
SET       Format= --extract-audio --format "773/338/258/328/774/327/256/141/251/22/140/38/37/35/34/59/78/18/250/46/45/44/43"
) ELSE (IF "%SectionsAudio%"=="1" (
SET       Format= --extract-audio --audio-format %AudioFormat% --audio-quality %AudioQuality%
) ELSE (IF "%CustomFormatVideo%"=="1" (
SET       Format= --format "bv*+ba/b" --merge-output-format mkv
) ELSE (IF "%CustomFormatVideo%"=="2" (
SET       Format= -S "+size,+br,+res,+fps" --merge-output-format mkv
) ELSE (IF "%CustomFormatVideo%"=="3" (
SET       Format= -S "+size,+br" --merge-output-format mkv
) ELSE (IF "%CustomCodec%"=="avc" (
SET       Format= --format "(bestvideo*[vcodec~='^((he|a)vc|h26[45])'][height<=%VideoResolution%][fps<=%VideoFPS%]/bestvideo[ext=mp4]) + (bestaudio[acodec=opus][format_note*=original]/bestaudio[acodec~='^(mp?4a|aac)'][format_note*=original]/bestaudio[container*=dash]) / (bestvideo*[height<=%VideoResolution%][fps<=%VideoFPS%]+ba/b)" --merge-output-format mp4 --postprocessor-args "Merger:-v quiet -y -threads 0 -vcodec copy -acodec %ENCODER% -b:a %AUDIO_BITRATE%k -ar %AUDIO_SAMPLING_RATE% -cutoff %CUTOFF%"
) ELSE (IF "%CustomCodec%"=="vp9" (
SET       Format= --format "(bestvideo*[vcodec~='^(vp9.2|vp09|vp9)'][height<=%VideoResolution%][fps<=%VideoFPS%]/bestvideo*[height<=%VideoResolution%][fps<=%VideoFPS%]/bestvideo)+(bestaudio[acodec=opus][format_note*=original]/bestaudio[acodec~='^(mp?4a|aac)'][format_note*=original]/bestaudio[container*=dash])/(bestvideo*[height<=%VideoResolution%][fps<=%VideoFPS%]+ba/b)" --merge-output-format mkv --postprocessor-args "Merger:-v quiet -y -threads 0 -vcodec copy -acodec %ENCODER%  -b:a %AUDIO_BITRATE%k -ar %AUDIO_SAMPLING_RATE%-cutoff %CUTOFF%"
) ELSE (IF "%CustomCodec%"=="av1" (
SET       Format= --format "(bestvideo*[vcodec^=av01][height<=%VideoResolution%][fps<=%VideoFPS%]/bestvideo[ext=mp4])+(bestaudio[acodec=opus][format_note*=original]/bestaudio[acodec~='^(mp?4a|aac)'][format_note*=original]/bestaudio[container*=dash]) / (bestvideo*[height<=%VideoResolution%][fps<=%VideoFPS%]+ba/b)" --merge-output-format mp4 --postprocessor-args "Merger:-v quiet -y -threads 0 -vcodec copy -acodec %ENCODER% -b:a %AUDIO_BITRATE%k -ar %AUDIO_SAMPLING_RATE% -cutoff %CUTOFF%"
) ELSE (IF "%SectionsVideo%"=="1" (
SET       Format= --format "(bestvideo*[height=?%VideoResolution%][fps=?%VideoFPS%])+(bestaudio[acodec=opus][format_note*=original]/bestaudio[acodec~='^(mp?4a|aac)'][format_note*=original]/bestaudio[container*=dash])/(bestvideo*[height<=?%VideoResolution%][fps<=?%VideoFPS%]+ba/b)" --merge-output-format mkv --postprocessor-args "Merger:-v quiet -y -threads 0 -vcodec copy -acodec %ENCODER% -b:a %AUDIO_BITRATE%k -ar %AUDIO_SAMPLING_RATE% -cutoff %CUTOFF%"
)))))))))))))))))))))))
SET     Subtitle=
SET     Comments=
IF "%usecookies%"=="1" (
SET Authenticate= --cookies "%COOKIES_PATH%"
) ELSE (
SET Authenticate=
)
IF DEFINED use_pl_yandextranslate (
SET    AdobePass= --use-extractors YandexTranslate --audio-multistreams --extractor-args YandexTranslate:orig_volume=0.3:codec=libopus
) ELSE (
SET    AdobePass=
)
SET   PreProcess= --parse-metadata "%%(epoch>%%Y-%%m-%%d)s:%%(meta_download_date)s" --parse-metadata "%%(album,playlist_title,playlist,channel)s:%%(meta_album)s" --parse-metadata "%%(album_artist,album_artists,uploader)s:%%(meta_album_artist)s" --parse-metadata "%%(artist,artists.0,creator,uploader)s:%%(meta_artist)s" --parse-metadata "%%(average_rating)s:%%(meta_rating)s" --parse-metadata "%%(composer,composers)s:%%(meta_composer)s" --parse-metadata "%%(disc_number)s:%%(meta_disc)s" --parse-metadata "%%(dislike_count)s:%%(meta_dislikes)s" --parse-metadata "%%(genre,genres)s:%%(meta_genre)s" --parse-metadata "%%(like_count)s:%%(meta_likes)s" --parse-metadata "%%(playlist_index,track_number,autonumber+1|01)02d:%%(meta_track)s" --parse-metadata "%%(release_date>%%Y-%%m-%%d,release_year,upload_date>%%Y-%%m-%%d)s:%%(meta_date)s" --parse-metadata "%%(view_count)s:%%(meta_views)s" --parse-metadata ":(?P<meta_longdescription>)" --parse-metadata ":(?P<meta_synopsis>)" --parse-metadata ":(?P<meta_purl>)" --parse-metadata "webpage_url:%%(meta_www)s" --replace-in-metadata meta_album_artist " - Topic" "" --replace-in-metadata meta_date "^NA$" "" --replace-in-metadata meta_rating "^NA$" "" --replace-in-metadata meta_views "^NA$" "" --replace-in-metadata meta_likes "^NA$" "" --replace-in-metadata meta_dislikes "^NA$" "" --replace-in-metadata meta_disc "^NA$" "" --replace-in-metadata meta_composer "^NA$" "" --replace-in-metadata meta_album "%%(channel)s" "%%(channel)s Videos" --replace-in-metadata meta_album "^NA$" "" --replace-in-metadata meta_genre "^NA$" "" --replace-in-metadata title "/" "⁄" --replace-in-metadata title ":" "꞉" --replace-in-metadata album "/" "⁄" --replace-in-metadata album ":" "꞉"
IF "%SectionsVideo%"=="1" (
SET  PostProcess= --embed-metadata --compat-options no-attach-info-json --force-keyframes-at-cuts
) ELSE (IF "%CustomFormat-opus%"=="1" (
SET  PostProcess= --embed-metadata --compat-options no-attach-info-json --force-keyframes-at-cuts
) ELSE (IF "%CustomFormat-opus%"=="3" (
SET  PostProcess= --embed-metadata --compat-options no-attach-info-json --force-keyframes-at-cuts
) ELSE (
SET  PostProcess= --embed-metadata --compat-options no-attach-info-json
)))
:: setting variables for continue menu
SET Downloaded-Video=& SET Downloaded-Audio=& SET Downloaded-Manual=& SET Downloaded-Manual-Single=& SET Downloaded-Comments=& SET Downloaded-Subs=& SET Downloaded-Stream=& SET Downloaded-Sections=1& SET Downloaded-Quick=& GOTO :doYTDL-check

::
::
:: DOWNLOADER
::
::

:doYTDL-check
SET doYTDL=
cls
ECHO %Magenta-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Magenta-s%│%ColorOff%  %Magenta-s%•%ColorOff%  Check Parameters:!padding:~1,-23!%Magenta-s%│%ColorOff%
ECHO %Magenta-s%┝%separator:~1,-1%┥%ColorOff%
IF DEFINED OutTemplate (
ECHO    %Green-n%›%ColorOff%  Output:%OutTemplate%
)
IF DEFINED Options (
ECHO    %Green-n%›%ColorOff%  Options:%Options%
)
IF DEFINED Network (
ECHO    %Green-n%›%ColorOff%  Network:%Network%
)
IF DEFINED GeoRestrict (
ECHO    %Green-n%›%ColorOff%  GeoRestrict:%GeoRestrict%
)
IF DEFINED Select (
ECHO    %Green-n%›%ColorOff%  Select:%Select%
)
IF DEFINED Download (
ECHO    %Green-n%›%ColorOff%  Download:%Download%
)
IF DEFINED Sponsorblock (
ECHO    %Green-n%›%ColorOff%  Sponsorblock:%Sponsorblock%
)
IF DEFINED FileSystem (
ECHO    %Green-n%›%ColorOff%  FileSystem:%FileSystem%
)
IF DEFINED Thumbnail (
ECHO    %Green-n%›%ColorOff%  Thumbnail:%Thumbnail%
)
IF DEFINED Verbosity (
ECHO    %Green-n%›%ColorOff%  Verbosity:%Verbosity%
)
IF DEFINED WorkArounds (
ECHO    %Green-n%›%ColorOff%  WorkArounds:%WorkArounds%
)
IF DEFINED Format (
ECHO    %Green-n%›%ColorOff%  Format:%Format%
)
IF DEFINED Subtitle (
ECHO    %Green-n%›%ColorOff%  Subtitle:%Subtitle%
)
IF DEFINED Comments (
ECHO    %Green-n%›%ColorOff%  Comments:%Comments%
)
IF DEFINED Authenticate (
ECHO    %Green-n%›%ColorOff%  Authenticate:%Authenticate%
)
IF DEFINED AdobePass (
ECHO    %Green-n%›%ColorOff%  AdobePass:%AdobePass%
)
IF DEFINED PreProcess (
ECHO    %Green-n%›%ColorOff%  PreProcess:%PreProcess%
)
IF DEFINED PostProcess (
ECHO    %Green-n%›%ColorOff%  PostProcess:%PostProcess%
)
IF DEFINED ReplayGain (
ECHO    %Green-n%›%ColorOff%  ReplayGain:%ReplayGain%
)
IF DEFINED duration_filter (
ECHO    %Green-n%›%ColorOff%  Duration:%Duration%
)
IF DEFINED date_filter (
ECHO    %Green-n%›%ColorOff%  Date:%Date_Filter%
)
IF DEFINED DownloadList (
ECHO    %Green-n%›%ColorOff%  URLs List: "%Underline%%URL%%ColorOff%"
) ELSE (
ECHO    %Green-n%›%ColorOff%  URL: "%Underline%%URL%%ColorOff%"
)
ECHO %Magenta-s%╰%separator:~1,-1%╯%ColorOff%
:: test solution to reset without script quiting
SET /P doYTDL=%BS%   %Cyan-n%› %ColorOff% '%Blue-s%Enter%ColorOff%' to download, '%Blue-s%r%ColorOff%' to return to Main Menu: 
IF NOT DEFINED doYTDL GOTO :doYTDL
IF "!doYTDL!"=="r" SET Downloaded-Video=& SET Downloaded-Audio=& SET Downloaded-Manual=& SET Downloaded-Manual-Single=& SET Downloaded-Comments=& SET Downloaded-Subs=& SET AudioQuality=& SET DownloadList=& SET VideoResolution=& SET VideoFPS=& SET CustomFormatVideo=& SET StreamAudioFormat=& SET CustomFormat-m4a=& SET CustomFormat-mp3=& SET quality_libfdk=& SET CustomFormat-opus=& SET StreamVideoFormat=& SET CommentPreset=& SET SectionsAudio=& SET SectionsVideo=& SET DoSections=& SET Downloaded-Sections=& SET Downloaded-Stream=& SET OnlyNew=& SET Downloaded-Quick=& SET SubsPreset=& SET FormatTitle=& SET CustomFormat-ogg=& SET CropThumb=& SET VariousArtists=& SET quality_simple=& SET CustomFormatAudio=& SET CustomChapters=& SET ReplayGainPreset=& SET BestAudio=& SET aac-at-param-1=& SET aac-at-param-2=& SET aac-at-param-3=& SET aac-at-param-4=& SET aac-at-param-5=& SET CustomCodec=& SET ContinueHook=& SET ALBUM=& SET !doYTDL!=& GOTO :start
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  Invalid choice, please try again.!padding:~1,-39!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
timeout /t 2 >nul
GOTO :doYTDL-check

:doYTDL
cls
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  DOWNLOADING...!padding:~1,-20!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
IF DEFINED DownloadList (
"%YTDLP_PATH%"%OutTemplate%%Options%%Format%%Select%%Network%%GeoRestrict%%Download%%Sponsorblock%%FileSystem%%Thumbnail%%Verbosity%%WorkArounds%%Subtitle%%Comments%%Authenticate%%AdobePass%%PreProcess%%PostProcess%%ReplayGain%%Duration%%Date_Filter% 2>&1 | "%MOREUTILS_PATH%" ts "[%%T]" | "%TEE_PATH%" "%LOG_PATH%"
) ELSE (IF "%Downloaded-Sections%"=="1" (
"%YTDLP_PATH%"%OutTemplate%%Options%%Format%%Select%%Network%%GeoRestrict%%Download%%Sponsorblock%%FileSystem%%Thumbnail%%Verbosity%%WorkArounds%%Subtitle%%Comments%%Authenticate%%AdobePass%%PreProcess%%PostProcess% "%URL%" 2>&1 | "%MOREUTILS_PATH%" ts "[%%T]" | "%TEE_PATH%" "%LOG_PATH%"
) ELSE (
"%YTDLP_PATH%"%OutTemplate%%Options%%Format%%Select%%Network%%GeoRestrict%%Download%%Sponsorblock%%FileSystem%%Thumbnail%%Verbosity%%WorkArounds%%Subtitle%%Comments%%Authenticate%%AdobePass%%PreProcess%%PostProcess%%ReplayGain%%Duration%%Date_Filter% "%URL%" 2>&1 | "%MOREUTILS_PATH%" ts "%Cyan-n%[%%T]%ColorOff%" | "%TEE_PATH%" "%LOG_PATH%"
))
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  COLLECTED ERRORS!padding:~1,-22!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
IF EXIST "%LOG_PATH%" FOR /f "delims=" %%j IN ('type "%LOG_PATH%" ^| findstr /i /r "WARNING: ERROR:"') DO ECHO %%j
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Done. Press any key.!padding:~1,-26!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
PAUSE >nul
GOTO :continue

:doYTDL-check-smart
cls
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  SMART SPLITTER: Exporting long videos from Source URL to "%SPLITTER_LIST_PATH%"...
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
"%YTDLP_PATH%" --simulate --skip-download --flat-playlist --parse-metadata "%%(chapters|)l:(?P<has_chapters>.)" --match-filters "^!is_live&has_chapters&duration^>840" --match-filters "^!is_live&duration^>840" --print-to-file "%%(webpage_url)s" "%SPLITTER_LIST_PATH%" "%URL%"
timeout /t 1 >nul
IF EXIST "%SPLITTER_LIST_PATH%" (
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  SMART SPLITTER: Continuing to Splitter.!padding:~1,-45!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
SET URL=%SPLITTER_LIST_PATH%
SET DownloadList=1
SET smart_splitter=2
timeout /t 2 >nul
IF "%Downloaded-Video%"=="1" (GOTO :doYTDL-video-preset-1) ELSE (IF "%Downloaded-Audio%"=="1" (GOTO :doYTDL-audio-preset-1))
) ELSE (
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  SMART SPLITTER: No matching videos found. Skipping...!padding:~1,-59!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
IF EXIST "%SPLITTER_LIST_PATH%" del /f /q "%SPLITTER_LIST_PATH%" >nul 2>&1
timeout /t 2 >nul
GOTO :continue
)

:doYTDL-do-smart
cls
:: this was for long debugging
REM ECHO   %Green-n%› %ColorOff%  Select:%Select%
REM ECHO   %Green-n%› %ColorOff%  DownloadList:%DownloadList%
REM ECHO   %Green-n%› %ColorOff%  smart_splitter:%smart_splitter%
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  SMART SPLITTER: Fetching URL...!padding:~1,-37!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
"%YTDLP_PATH%"%OutTemplate%%Options%%Format%%Select%%Network%%GeoRestrict%%Download%%Sponsorblock%%FileSystem%%Thumbnail%%Verbosity%%WorkArounds%%Subtitle%%Comments%%Authenticate%%AdobePass%%PreProcess%%PostProcess%%ReplayGain%%Duration%%Date_Filter% 2>&1 | "%MOREUTILS_PATH%" ts "[%%T]" | "%TEE_PATH%" "%LOG_PATH%"
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  COLLECTED ERRORS!padding:~1,-22!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
IF EXIST "%LOG_PATH%" FOR /f "delims=" %%j IN ('type "%LOG_PATH%" ^| findstr /i /r "WARNING: ERROR:"') DO ECHO %%j
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  SMART SPLITTER: Done. Press any key.!padding:~1,-42!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
SET smart_splitter=1
:: need to delete it as --print-to-file only adding to list not renews the list
:: don't know what to do on errors yet
IF EXIST "%SPLITTER_LIST_PATH%" del /f /q "%SPLITTER_LIST_PATH%">nul 2>&1
PAUSE >nul
SET Downloaded-Video=& SET Downloaded-Audio=& SET Downloaded-Manual=& SET Downloaded-Manual-Single=& SET Downloaded-Comments=& SET Downloaded-Subs=& SET AudioQuality=& SET DownloadList=& SET VideoResolution=& SET VideoFPS=& SET CustomFormatVideo=& SET StreamAudioFormat=& SET CustomFormat-m4a=& SET CustomFormat-mp3=& SET quality_libfdk=& SET CustomFormat-opus=& SET StreamVideoFormat=& SET CommentPreset=& SET SectionsAudio=& SET SectionsVideo=& SET DoSections=& SET Downloaded-Sections=& SET Downloaded-Stream=& SET OnlyNew=& SET Downloaded-Quick=& SET SubsPreset=& SET FormatTitle=& SET CustomFormat-ogg=& SET CropThumb=& SET VariousArtists=& SET quality_simple=& SET CustomFormatAudio=& SET CustomChapters=& SET ReplayGainPreset=& SET BestAudio=& SET aac-at-param-1=& SET aac-at-param-2=& SET aac-at-param-3=& SET aac-at-param-4=& SET aac-at-param-5=& SET CustomCodec=& SET ContinueHook=& SET ALBUM=& SET doYTDL=& GOTO :start

:doYTDL-stream
cls
ECHO %Magenta-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Magenta-s%│%ColorOff%  %Magenta-s%•%ColorOff%  Check Parameters:!padding:~1,-23!%Magenta-s%│%ColorOff%
ECHO %Magenta-s%┝%separator:~1,-1%┥%ColorOff%
IF DEFINED OutTemplate (
ECHO    %Green-n%›%ColorOff%  Output:%OutTemplate%
)
IF DEFINED Options (
ECHO    %Green-n%›%ColorOff%  Options:%Options%
)
IF DEFINED Network (
ECHO    %Green-n%›%ColorOff%  Network:%Network%
)
IF DEFINED GeoRestrict (
ECHO    %Green-n%›%ColorOff%  GeoRestrict:%GeoRestrict%
)
IF DEFINED Select (
ECHO    %Green-n%›%ColorOff%  Select:%Select%
)
IF DEFINED Download (
ECHO    %Green-n%›%ColorOff%  Download:%Download%
)
IF DEFINED Sponsorblock (
ECHO    %Green-n%›%ColorOff%  Sponsorblock:%Sponsorblock%
)
IF DEFINED FileSystem (
ECHO    %Green-n%›%ColorOff%  FileSystem:%FileSystem%
)
IF DEFINED Thumbnail (
ECHO    %Green-n%›%ColorOff%  Thumbnail:%Thumbnail%
)
IF DEFINED Verbosity (
ECHO    %Green-n%›%ColorOff%  Verbosity:%Verbosity%
)
IF DEFINED WorkArounds (
ECHO    %Green-n%›%ColorOff%  WorkArounds:%WorkArounds%
)
IF DEFINED Format (
ECHO    %Green-n%›%ColorOff%  Format:%Format%
)
IF DEFINED Subtitle (
ECHO    %Green-n%›%ColorOff%  Subtitle:%Subtitle%
)
IF DEFINED Comments (
ECHO    %Green-n%›%ColorOff%  Comments:%Comments%
)
IF DEFINED Authenticate (
ECHO    %Green-n%›%ColorOff%  Authenticate:%Authenticate%
)
IF DEFINED AdobePass (
ECHO    %Green-n%›%ColorOff%  AdobePass:%AdobePass%
)
IF DEFINED PreProcess (
ECHO    %Green-n%›%ColorOff%  PreProcess:%PreProcess%
)
IF DEFINED PostProcess (
ECHO    %Green-n%›%ColorOff%  PostProcess:%PostProcess%
)
IF DEFINED ReplayGain (
ECHO   %Green-s%› %ColorOff%  ReplayGain:%ReplayGain%
)
IF DEFINED duration_filter (
ECHO   %Green-s%› %ColorOff%  Duration:%Duration%
)
IF DEFINED date_filter (
ECHO   %Green-s%› %ColorOff%  Date:%Date_Filter%
)
ECHO    %Green-n%›%ColorOff%  URL: "%Underline%%URL%%ColorOff%"
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  STREAMING...!padding:~1,-18!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
IF DEFINED StreamVideoFormat (
"%YTDLP_PATH%"%Options%%Format%%Select%%Network%%GeoRestrict%%Sponsorblock%%Thumbnail%%Verbosity%%WorkArounds%%Subtitle%%Comments%%Authenticate%%AdobePass%%PreProcess%%PostProcess%%FileSystem%%OutTemplate%%Download% "%URL%"| "%VIDEO_PLAYER_PATH%" -
) ELSE (IF DEFINED StreamAudioFormat (
"%YTDLP_PATH%"%Options%%Format%%Select%%Network%%GeoRestrict%%Sponsorblock%%Thumbnail%%Verbosity%%WorkArounds%%Subtitle%%Comments%%Authenticate%%AdobePass%%PreProcess%%PostProcess%%FileSystem%%OutTemplate%%Download% "%URL%"| "%AUDIO_PLAYER_PATH%" -
))
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Done. Press any key.!padding:~1,-26!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
PAUSE >nul
GOTO :continue

:doYTDL-quick
cls
IF "%Downloaded-Quick%"=="1" (
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  DOWNLOADING...!padding:~1,-20!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
"%YTDLP_PATH%"%Options%%Format%%Select%%Network%%GeoRestrict%%Download%%Sponsorblock%%FileSystem%%Thumbnail%%Verbosity%%WorkArounds%%Subtitle%%Comments%%Authenticate%%AdobePass%%PreProcess%%PostProcess%%OutTemplate% "%URL%" 2>&1 | "%MOREUTILS_PATH%" ts "[%%T]" | "%TEE_PATH%" "%LOG_PATH%"
SET clipboard=
SET Downloaded-Quick=1
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  COLLECTED ERRORS!padding:~1,-22!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
IF EXIST "%LOG_PATH%" FOR /f "delims=" %%j IN ('type "%LOG_PATH%" ^| findstr /i /r "WARNING: ERROR:"') DO ECHO %%j
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Done. Press any key.!padding:~1,-26!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
PAUSE >nul
GOTO :continue
) ELSE (
ECHO %Magenta-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Magenta-s%│%ColorOff%  %Magenta-s%•%ColorOff%  Check Parameters:!padding:~1,-23!%Magenta-s%│%ColorOff%
ECHO %Magenta-s%┝%separator:~1,-1%┥%ColorOff%
IF DEFINED OutTemplate (
ECHO    %Green-n%›%ColorOff%  Output:%OutTemplate%
)
IF DEFINED Options (
ECHO    %Green-n%›%ColorOff%  Options:%Options%
)
IF DEFINED Network (
ECHO    %Green-n%›%ColorOff%  Network:%Network%
)
IF DEFINED GeoRestrict (
ECHO    %Green-n%›%ColorOff%  GeoRestrict:%GeoRestrict%
)
IF DEFINED Select (
ECHO    %Green-n%›%ColorOff%  Select:%Select%
)
IF DEFINED Download (
ECHO    %Green-n%›%ColorOff%  Download:%Download%
)
IF DEFINED Sponsorblock (
ECHO    %Green-n%›%ColorOff%  Sponsorblock:%Sponsorblock%
)
IF DEFINED FileSystem (
ECHO    %Green-n%›%ColorOff%  FileSystem:%FileSystem%
)
IF DEFINED Thumbnail (
ECHO    %Green-n%›%ColorOff%  Thumbnail:%Thumbnail%
)
IF DEFINED Verbosity (
ECHO    %Green-n%›%ColorOff%  Verbosity:%Verbosity%
)
IF DEFINED WorkArounds (
ECHO    %Green-n%›%ColorOff%  WorkArounds:%WorkArounds%
)
IF DEFINED Format (
ECHO    %Green-n%›%ColorOff%  Format:%Format%
)
IF DEFINED Subtitle (
ECHO    %Green-n%›%ColorOff%  Subtitle:%Subtitle%
)
IF DEFINED Comments (
ECHO    %Green-n%›%ColorOff%  Comments:%Comments%
)
IF DEFINED Authenticate (
ECHO    %Green-n%›%ColorOff%  Authenticate:%Authenticate%
)
IF DEFINED AdobePass (
ECHO    %Green-n%›%ColorOff%  AdobePass:%AdobePass%
)
IF DEFINED PreProcess (
ECHO    %Green-n%›%ColorOff%  PreProcess:%PreProcess%
)
IF DEFINED PostProcess (
ECHO    %Green-n%›%ColorOff%  PostProcess:%PostProcess%
)
IF DEFINED ReplayGain (
ECHO   %Green-s%› %ColorOff%  ReplayGain:%ReplayGain%
)
IF DEFINED duration_filter (
ECHO   %Green-s%› %ColorOff%  Duration:%Duration%
)
IF DEFINED date_filter (
ECHO   %Green-s%› %ColorOff%  Date:%Date_Filter%
)
ECHO    %Green-n%›%ColorOff%  URL: "%Underline%%URL%%ColorOff%"
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  DOWNLOADING...!padding:~1,-20!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
"%YTDLP_PATH%"%Options%%Format%%Select%%Network%%GeoRestrict%%Download%%Sponsorblock%%FileSystem%%Thumbnail%%Verbosity%%WorkArounds%%Subtitle%%Comments%%Authenticate%%AdobePass%%PreProcess%%PostProcess%%OutTemplate% "%URL%" 2>&1 | "%MOREUTILS_PATH%" ts "[%%T]" | "%TEE_PATH%" "%LOG_PATH%"
SET clipboard=
SET Downloaded-Quick=1
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  COLLECTED ERRORS!padding:~1,-22!%Red-s%│%ColorOff%
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
IF EXIST "%LOG_PATH%" FOR /f "delims=" %%j IN ('type "%LOG_PATH%" ^| findstr /i /r "WARNING: ERROR:"') DO ECHO %%j
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Done. Press any key.!padding:~1,-26!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
PAUSE >nul
GOTO :continue
)

::
::
:: DRAGGED URLs/LISTs DOWNLOADER
::
::

:doYTDL-drag url[.txt] [...]
:: exit if no parameters, display commandline, call yt-dlp
IF ""=="%~1" EXIT /B 0
IF "%Downloaded-Drag%"=="1" (
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  DOWNLOADING...!padding:~1,-20!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
"%YTDLP_PATH%"%Options%%Format%%Select%%Network%%GeoRestrict%%Download%%Sponsorblock%%FileSystem%%Thumbnail%%Verbosity%%WorkArounds%%Subtitle%%Comments%%Authenticate%%AdobePass%%PreProcess%%PostProcess%%OutTemplate% "%*"
IF %APP_ERR% NEQ 0 (
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  %Red-s%ERROR%ColorOff%: yt-dlp ErrorLevel is %Cyan-s%%APP_ERR%%ColorOff%.
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
)
SET Downloaded-Drag=1
timeout /t 2 >nul
EXIT /B 0
) ELSE (
ECHO %Magenta-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Magenta-s%│%ColorOff%  %Magenta-s%•%ColorOff%  Check Parameters:!padding:~1,-23!%Magenta-s%│%ColorOff%
ECHO %Magenta-s%┝%separator:~1,-1%┥%ColorOff%
IF DEFINED OutTemplate (
ECHO    %Green-n%›%ColorOff%  Output:%OutTemplate%
)
IF DEFINED Options (
ECHO    %Green-n%›%ColorOff%  Options:%Options%
)
IF DEFINED Network (
ECHO    %Green-n%›%ColorOff%  Network:%Network%
)
IF DEFINED GeoRestrict (
ECHO    %Green-n%›%ColorOff%  GeoRestrict:%GeoRestrict%
)
IF DEFINED Select (
ECHO    %Green-n%›%ColorOff%  Select:%Select%
)
IF DEFINED Download (
ECHO    %Green-n%›%ColorOff%  Download:%Download%
)
IF DEFINED Sponsorblock (
ECHO    %Green-n%›%ColorOff%  Sponsorblock:%Sponsorblock%
)
IF DEFINED FileSystem (
ECHO    %Green-n%›%ColorOff%  FileSystem:%FileSystem%
)
IF DEFINED Thumbnail (
ECHO    %Green-n%›%ColorOff%  Thumbnail:%Thumbnail%
)
IF DEFINED Verbosity (
ECHO    %Green-n%›%ColorOff%  Verbosity:%Verbosity%
)
IF DEFINED WorkArounds (
ECHO    %Green-n%›%ColorOff%  WorkArounds:%WorkArounds%
)
IF DEFINED Format (
ECHO    %Green-n%›%ColorOff%  Format:%Format%
)
IF DEFINED Subtitle (
ECHO    %Green-n%›%ColorOff%  Subtitle:%Subtitle%
)
IF DEFINED Comments (
ECHO    %Green-n%›%ColorOff%  Comments:%Comments%
)
IF DEFINED Authenticate (
ECHO    %Green-n%›%ColorOff%  Authenticate:%Authenticate%
)
IF DEFINED AdobePass (
ECHO    %Green-n%›%ColorOff%  AdobePass:%AdobePass%
)
IF DEFINED PreProcess (
ECHO    %Green-n%›%ColorOff%  PreProcess:%PreProcess%
)
IF DEFINED PostProcess (
ECHO    %Green-n%›%ColorOff%  PostProcess:%PostProcess%
)
IF DEFINED ReplayGain (
ECHO    %Green-n%›%ColorOff%  ReplayGain:%ReplayGain%
)
IF DEFINED duration_filter (
ECHO    %Green-n%›%ColorOff%  Duration:%Duration%
)
IF DEFINED date_filter (
ECHO    %Green-n%›%ColorOff%  Date:%Date_Filter%
)
ECHO    %Green-n%›%ColorOff%  URL: %Underline%%*%ColorOff%
ECHO %Green-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Green-s%│%ColorOff%  %Green-s%•%ColorOff%  Press any key to continue!padding:~1,-31!%Green-s%│%ColorOff%
ECHO %Green-s%╰%separator:~1,-1%╯%ColorOff%
PAUSE >nul
ECHO %Yellow-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Yellow-s%│%ColorOff%  %Yellow-s%•%ColorOff%  DOWNLOADING...!padding:~1,-20!%Yellow-s%│%ColorOff%
ECHO %Yellow-s%╰%separator:~1,-1%╯%ColorOff%
"%YTDLP_PATH%"%Options%%Format%%Select%%Network%%GeoRestrict%%Download%%Sponsorblock%%FileSystem%%Thumbnail%%Verbosity%%WorkArounds%%Subtitle%%Comments%%Authenticate%%AdobePass%%PreProcess%%PostProcess%%OutTemplate% "%*"
IF %APP_ERR% NEQ 0 (
ECHO %Red-s%╭%separator:~1,-1%╮%ColorOff%
ECHO %Red-s%│%ColorOff%  %Red-s%•%ColorOff%  %Red-s%ERROR%ColorOff%: yt-dlp ErrorLevel is %Cyan-s%%APP_ERR%%ColorOff%.
ECHO %Red-s%╰%separator:~1,-1%╯%ColorOff%
)
SET Downloaded-Drag=1
timeout /t 2 >nul
EXIT /B 0
)

