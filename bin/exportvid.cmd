@echo off

rem exportvid.cmd: Version 0.3
rem  part of Exportvid package (see below)
rem
rem exportvid: Export most video files to a chosen platform/format
rem
rem  (c) Copyright 2011 Rowan Thorpe <rowan _at_ rowanthorpe [dot] com>
rem
rem    This program is free software: you can redistribute it and/or modify
rem    it under the terms of the GNU Affero General Public License as published by
rem    the Free Software Foundation, either version 3 of the License, or
rem    (at your option) any later version.
rem
rem    This program is distributed in the hope that it will be useful,
rem    but WITHOUT ANY WARRANTY; without even the implied warranty of
rem    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
rem    GNU Affero General Public License for more details.
rem
rem    You should have received a copy of the GNU Affero General Public License
rem    along with this program.  If not, see <http://www.gnu.org/licenses/>.

set errormessage=
set oldpwd=%CD%
set COPYCMD=/Y
set option=
goto globaldefaults

:help
echo Usage: export-video [-h^|-d^|-1^|-n^|-f^|-o^|-s^|-t^|--] source file(s)
echo   -h     : this help message
echo     Global Options:
echo   -f x   : output format (default=vimeo)
echo   -1^|-2  : single/double-pass mode (default=double pass if format allows)
echo   -S^|-nS : attempt/don't make output streamable (default=attempt)
echo   -d^|-nd : deinterlace/don't (default=don't)
echo   -r     : reset to global default settings
echo     Per-output-file Options:
echo   -o x   : output filename for next output (default=^~dpn1%%fileext%%)
echo   -i x   : number of input files to combine for next output (default=1)
echo   -s x   : start-point for next output (in seconds, default=beginning)
echo   -t x   : time/duration for next output (in seconds, default=all)
echo   -X     : show source code of this program
goto cleanexit
:endhelp

:showsource
type %~dpnx0
if ERRORLEVEL 1 (
	set errormessage=Problem showing source code of %~dpnx0
	goto errorexit
)
goto cleanexit
:endshowsource

:cleanexit
cd /d "%oldpwd%" >nul 2>&1
if ERRORLEVEL 1 (
	echo Error: Problem returning to original directory
	exit /b 1
)
exit /b
:endcleanexit

:errorexit
cd /d "%oldpwd%" >nul 2>&1
echo Error: %errormessage%
exit /b 1
:enderrorexit

:globaldefaults
set platform=vimeo
set fileext=.mp4
set deinterlace=0
set numpasses=-1
set makestreamable=-1
set firstpasspresetstr=
set normalpasspresetstr=
set firstpassparamsstr=
set normalpassparamsstr=
set deinterlacestr=
:endglobaldefaults

:perfiledefaults
set inputstr=
set destfile=
set numinputs=1
set startpoint=-1
set duration=-1
set startpointstr=
set durationstr=
:endperfiledefaults

:getopts
if [%1]==[] goto cleanexit
if [%1]==[-h] goto help
if [%1]==[-X] goto showsource
if [%1]==[-d] (
	set deinterlace=1
	shift
	goto getopts
)
if [%1]==[-nd] (
	set deinterlace=0
	shift
	goto getopts
)
if [%1]==[-1] (
	set numpasses=1
	shift
	goto getopts
)
if [%1]==[-2] (
	set numpasses=2
	shift
	goto getopts
)
if [%1]==[-S] (
	set makestreamable=1
	shift
	goto getopts
)
if [%1]==[-nS] (
	set makestreamable=0
	shift
	goto getopts
)
if [%1]==[-r] (
	shift
	goto globaldefaults
)
if [%1]==[-i] (
	set numinputs=%2
	shift
	shift
	goto getopts
)
if [%1]==[-f] (
	if [%2]==list (
		echo vimeo
		echo SGH-F480
		goto cleanexit
	)
	set platform=%2
	shift
	shift
	goto getopts
)
if [%1]==[-o] (
	set destfile=%2
	shift
	shift
	goto getopts
)
if [%1]==[-s] (
	set startpoint=%2
	shift
	shift
	goto getopts
)
if [%1]==[-t] (
	set duration=%2
	shift
	shift
	goto getopts
)
if [%1]==[--] (
	shift
	goto endgetopts
)
set option=%1
if [%option:~0,1%]==[-] (
	set errormessage=Unknown commandline option: %1
	goto errorexit
)
:endgetopts

:setup
rem This is the section to which you can add platform-specific settings.
rem NB: for user-friendliness the XXXXX are *platform* names, rather than filetypes
rem (so for example someone with a Samsung SGH-F480 won't need to know to create a
rem format of 3GP/h263-150kbps/amrnb-12.2kbps/176x144/15fps/etc...). If the output
rem format is exactly the same for different platforms it can be wrapped in a:
rem 
rem   if not %platform%==[platform1] if not %platform%==[platform2] goto after_these_settings
rem   ...settings here...
rem   :after_these_settings
rem 
rem Below is a skeleton to loosely base each one on (replace XXXXX and ?????):
rem 
rem if %platform%==XXXXX (
rem 	if %deinterlace%==-1 set deinterlace=?????
rem 	if %numpasses%==-1 set numpasses=?????
rem 	if %makestreamable%==-1 set makestreamable=?????
rem 	set fileext=?????
rem 	if exist %USERPROFILE%\.ffmpeg\?????-slow_firstpass.ffpreset (
rem 		set firstpasspresetstr=-fpre "%USERPROFILE%\.ffmpeg\?????-slow_firstpass.ffpreset"
rem 	) else (
rem 		set firstpasspresetstr=?????
rem 	)
rem 	if exist %USERPROFILE%\.ffmpeg\?????-slow.ffpreset (
rem 		set normalpasspresetstr=-fpre "%USERPROFILE%\.ffmpeg\?????-slow.ffpreset"
rem 	) else (
rem 		set normalpasspresetstr=?????
rem 	)
rem 	set firstpassparamsstr=-f ????? -r ????? -b ????? (-bt ?????) -s ????? -vcodec ????? -aspect ????? -an
rem 	set normalpassparamsstr=-f ????? -r ????? -b ????? (-bt ?????) -s ????? -vcodec ????? -aspect ????? -acodec ????? -ac ????? -ar ????? -ab ????? -vlang ????? -pix_fmt ????? -alang ????? -sample_fmt ????? -metadata ?????
rem 	goto endsetup
rem )
rem 
if %platform%==vimeo (
	if %numpasses%==-1 set numpasses=2
	if %makestreamable%==-1 set makestreamable=1
	set fileext=.mp4
	if exist %USERPROFILE%\.ffmpeg\libx264-slow_firstpass.ffpreset (
		set firstpasspresetstr=-fpre "%USERPROFILE%\.ffmpeg\libx264-slow_firstpass.ffpreset"
	) else (
		set firstpasspresetstr=-coder 1 -flags +loop -cmp +chroma -partitions -parti8x8-parti4x4-partp8x8-partb8x8 -me_method dia -subq 2 -me_range 16 -g 250 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 -b_strategy 2 -qcomp 0.6 -qmin 0 -qmax 69 -qdiff 4 -bf 3 -refs 1 -directpred 3 -trellis 0 -flags2 +bpyramid-mixed_refs+wpred-dct8x8+fastpskip -wpredp 2 -rc_lookahead 60
	)
	if exist %USERPROFILE%\.ffmpeg\libx264-slow.ffpreset (
		set normalpasspresetstr=-fpre "%USERPROFILE%\.ffmpeg\libx264-slow.ffpreset"
	) else (
		set normalpasspresetstr=-coder 1 -flags +loop -cmp +chroma -partitions +parti8x8+parti4x4+partp8x8+partb8x8 -me_method umh -subq 8 -me_range 16 -g 250 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 -b_strategy 2 -qcomp 0.6 -qmin 0 -qmax 69 -qdiff 4 -bf 3 -refs 5 -directpred 3 -trellis 1 -flags2 +bpyramid+mixed_refs+wpred+dct8x8+fastpskip -wpredp 2 -rc_lookahead 50
	)
	set firstpassparamsstr=-f mp4 -r 25 -b 1800k -bt 2400k -s 640x480 -vcodec libx264 -aspect 4:3 -an
	set normalpassparamsstr=-f mp4 -r 25 -b 1800k -bt 2400k -s 640x480 -vcodec libx264 -aspect 4:3 -acodec libfaac -ac 2 -ar 44100 -ab 320k
	goto endsetup
)
if %platform%==SGH-F480 (
	if %numpasses%==-1 set numpasses=1
	if %makestreamable%==-1 set makestreamable=0
	set fileext=.3gp
	set firstpasspresetstr=
	set normalpasspresetstr=
rem TODO: Find a locale-independent, portable wasy to set creation time from system time using batch-script (almost impossible - not worth it..?)
rem TODO: Parse and insert datetime metadata properly. This isn't working...
rem	for /f "tokens=1,2,3 delims=:., " %%a in ("%TIME%") do (
rem		set HOUR=%%a
rem		set MINUTE=%%b
rem		set SECOND=%%c
rem	)
rem	if [%HOUR:~1%]==[] set HOUR=0%HOUR%
rem	if [%MINUTE:~1%]==[] set MINUTE=0%MINUTE%
rem	if [%SECOND:~1%]==[] set SECOND=0%SECOND%
rem	for /f "tokens=2 delims= " %%a in ("%DATE%") do (
rem		for /f "tokens=1,2,3 delims=/.-" %%i in ("%%a") do (
rem			set DAY=%%i
rem			set MONTH=%%j
rem			set YEAR=%%k
rem		)
rem	)
	set normalpassparamsstr=-f 3gp -r 15 -b 150k -s 176x144 -vcodec h263 -aspect 4:3 -acodec libopencore_amrnb -ac 1 -ar 8000 -ab 12.2k -vlang eng -pix_fmt yuv420p -alang eng -sample_fmt flt -metadata major_brand=3gp4 -metadata minor_version=0 -metadata compatible_brands=3gp43gp5isom 
rem ... -metadata "creation_time=%YEAR%-%MONTH%-%DAY% %HOUR%:%MINUTE%:%SECOND%"
	goto endsetup
)
set errormessage=Internal error: unknown platform %platform%...!
goto errorexit
:endsetup

:setstrings
if not [%destfile%]==[] (
	for /f %%i in ("%destfile%") do (
		if exist "%%~dpnxi" (
			set errormessage=Output file already exists
			goto errorexit
		) else (
			set destfile=%%~dpnxi
		)
	)
)
if not [%startpoint%]==[-1] set startpointstr=-ss %startpoint%
if not [%duration%]==[-1] set durationstr=-t %duration%
if %deinterlace%==1 set deinterlacestr=-deinterlace
:endsetstrings

:setfilenames
set inputstr=
for /l %%i in (1,1,%numinputs%) do (
	if [%1]==[] (
		set errormessage=No source file given
		goto errorexit
	) else (
		if exist "%~dpnx1" (
			set inputstr=%inputstr% -i "%~dpnx1"
		) else (
			set errormessage=Source file "%~dpnx1" doesn't exist
			goto errorexit
		)
		if %%i==1 (
			if [%destfile%]==[] (
				if [%~x1]==[%fileext%] (
					set errormessage=First input file already has a %fileext% extension
					goto errorexit
				) else (
					if exist "%~dpn1%fileext%" (
						set errormessage=Output file "%~dpn1%fileext%" already exists
						goto errorexit
					) else (
						set destfile=%~dpn1%fileext%
					)
				)
			)
		)
		shift
	)
)
rem TODO Implement expanding and looping over wildcards as input, in which case remember something like the below...
rem  if [%~nx1]==[.] (
rem  	shift
rem  	goto setfilenames
rem  )
rem  if [%~nx1]==[..] (
rem  	shift
rem  	goto setfilenames
rem  )
:setfilenames

:debug
echo ====
echo Source file(s) string: %inputstr%
echo Destination file: %destfile%
echo Encode passes: %numpasses%
if %makestreamable%==1 (
	echo Will attempt to make output streamable
) else (
	echo Will not attempt to make output streamable
)
if %deinterlace%==1 (
	echo Will deinterlace input
) else (
	echo Will not deinterlace input
)
echo Platform: %platform%
echo File extension: %fileext%
if [%startpoint%]==[-1] (
	echo Start point: beginning
) else (
	echo Start point: %startpoint% seconds
)
if [%duration%]==[-1] (
	echo Duration: until the end
) else (
	echo Duration: %duration% seconds
)
echo First-pass parameters: %firstpassparamsstr%
echo Normal-pass parameters: %normalpassparamsstr%
echo First-pass preset argument(s): %firstpasspresetstr%
echo Normal-pass preset argument(s): %normalpasspresetstr%
echo ====
:enddebug

:transcode
cd /d "%TEMP%" >nul 2>&1
if ERRORLEVEL 1 (
	set errormessage=Problem changing to "%TEMP%" directory
	goto errorexit
)
if %numpasses%==2 (
	if exist *_2pass.log del /q *_2pass.log >nul 2>&1
	if ERRORLEVEL 1 (
		set errormessage=Problem removing log file from a previous run
		goto errorexit
	)
	if exist *_2pass.log.mbtree del /q *_2pass.log.mbtree >nul 2>&1
	if ERRORLEVEL 1 (
		set errormessage=Problem removing log mbtree file from a previous run
		goto errorexit
	)
	ffmpeg %inputstr% %startpointstr% %durationstr% %deinterlacestr% %firstpassparamsstr% %firstpasspresetstr% -pass 1 "%destfile%" >nul 2>&1
	if ERRORLEVEL 1 (
		set errormessage=Problem with first pass encode
		goto errorexit
	)
	echo Finished first pass
	ffmpeg -y %inputstr% %startpointstr% %durationstr% %deinterlacestr% %normalpassparamsstr% %normalpasspresetstr% -pass 2 "%destfile%" >nul 2>&1
	if ERRORLEVEL 1 (
		set errormessage=Problem with second pass encode
		goto errorexit
	)
	echo Finished second pass
) else (
	ffmpeg %inputstr% %startpointstr% %durationstr% %deinterlacestr% %normalpassparamsstr% %normalpasspresetstr% "%destfile%" >nul 2>&1
	if ERRORLEVEL 1 (
		set errormessage=Problem with single pass encode
		goto errorexit
	)
	echo Finished single pass
)
:endtranscode

:makestreamable
if %makestreamable%==1 (
	if %platform%==vimeo (
		for %%i in (%destfile%) do (
			qt-faststart "%destfile%" "%%~nxi.tmp" >nul 2>&1
			if ERRORLEVEL 1 (
				set errormessage=Problem with qt-faststart
				goto errorexit
			)
			move "%%nxi.tmp" "%destfile%" >nul 2>&1
			if ERRORLEVEL 1 (
				set errormessage=Problem moving faststart version of file
				goto errorexit
			)
			echo Finished qt-faststart
		)
	)
)
:endmakestreamable

:cleanup
if %numpasses%==2 (
	if exist *_2pass.log del /q *_2pass.log >nul 2>&1
	if ERRORLEVEL 1 (
		set errormessage=Problem removing log file from a previous run
		goto errorexit
	)
	if exist *_2pass.log.mbtree del /q *_2pass.log.mbtree >nul 2>&1
	if ERRORLEVEL 1 (
		set errormessage=Problem removing log mbtree file from a previous run
		goto errorexit
	)
	echo Finished cleanup
)
cd /d "%oldpwd%" >nul 2>&1
if ERRORLEVEL 1 (
	set errormessage=Problem returning to original directory
	goto errorexit
)
goto perfiledefaults
:endcleanup
