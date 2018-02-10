;   Description: Stat
;            OS: Linux (amd64)
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=27769
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2014 NicTheQuick
; 
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
; 
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
; 
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

CompilerIf #PB_Compiler_OS<>#PB_OS_Linux
  CompilerError "Linux only!"
CompilerEndIf
CompilerIf #PB_Compiler_Processor<>#PB_Processor_x64
  CompilerWarning "designed for amd64 / CAN work with i386"
CompilerEndIf


;{ from /usr/include/x86_64-linux-gnu/bits/types.h and /usr/include/x86_64-linux-gnu/bits/typesizes.h
Macro dev_t : q : EndMacro
Macro ino_t : i : EndMacro
Macro mode_t : l : EndMacro
Macro nlink_t : q : EndMacro
Macro uid_t : l : EndMacro
Macro gid_t : l : EndMacro
Macro off_t : i : EndMacro
Macro blksize_t : i : EndMacro
Macro blkcnt_t : i : EndMacro
Macro time_t : i : EndMacro
Macro size_t : i : EndMacro
;}

;{ from /usr/include/x86_64-linux-gnu/bits/confname.h
#_SC_GETPW_R_SIZE_MAX = 70
;}

;{ from /usr/include/unistd.h
ImportC ""
  ; /* Get the value of the system variable NAME.  */
  ; extern long int sysconf (int __name) __THROW;
  sysconf.i(__name.l)
EndImport
;}

;{ from /usr/include/x86_64-linux-gnu/sys/sysmacros.h
; __NTH (gnu_dev_major (unsigned long long int __dev))
; {
;   Return ((__dev >> 8) & 0xfff) | ((unsigned int) (__dev >> 32) & ~0xfff);
; }
;
; __extension__ __extern_inline __attribute_const__ unsigned int
; __NTH (gnu_dev_minor (unsigned long long int __dev))
; {
;   Return (__dev & 0xff) | ((unsigned int) (__dev >> 12) & ~0xff);
; }
; /* Access the functions With their traditional names.  */
; # Define major(dev) gnu_dev_major (dev)
; # Define minor(dev) gnu_dev_minor (dev)
Macro major(dev)
  (((dev >> 8) & $fff) | ((dev >> 32) & ~$fff))
EndMacro
Macro minor(dev)
  ((dev & $ff) | ((dev >> 12) & ~$ff))
EndMacro
;}

;{ from /usr/include/stat.h
Structure stat64
  st_dev.dev_t         ; ID of device containing file
  st_ino.ino_t         ; inode number
  st_nlink.nlink_t     ; number of hard links
  st_mode.mode_t       ; protection
  st_uid.uid_t         ; user ID of owner
  st_gid.gid_t         ; group ID of owner
  pad0.l
  st_rdev.dev_t         ; device ID (if special file)
  st_size.off_t         ; total size, in bytes
  st_blksize.blksize_t  ; blocksize for file system I/O
  st_blocks.blkcnt_t    ; number of 512B blocks allocated
  st_atime.time_t       ; time of last access
  st_atimensec.i
  st_mtime.time_t      ; time of last modification
  st_mtimensec.i
  st_ctime.time_t      ; time of last status change
  st_ctimensec.i
  __unused.i[3]
EndStructure

; Encoding of the file mode.
#__S_IFMT =   $F000   ; These bits determine file type.

; File types.
#__S_IFDIR  = $4000 ; Directory. (d)
#__S_IFCHR  = $2000 ; Character device. (c)
#__S_IFBLK  = $6000 ; Block device. (b)
#__S_IFREG  = $8000 ; Regular file. (-)
#__S_IFIFO  = $1000 ; FIFO. (p)
#__S_IFLNK  = $A000 ; Symbolic link. (l)
#__S_IFSOCK = $C000 ; Socket. (s)

; Protection bits.
#__S_ISUID  = $800 ; Set user ID on execution.
#__S_ISGID  = $400 ; Set group ID on execution.
#__S_ISVTX  = $200 ; Save swapped text after use (sticky).
#__S_IREAD  = $100 ; Read by owner. (r)
#__S_IWRITE = $80  ; Write by owner. (w)
#__S_IEXEC  = $40  ; Execute by owner. (x)

ImportC ""
  link.l(oldname.p-utf8, newname.p-utf8)
  
  ; extern int lstat64 (const char *__restrict __file,
  ;           struct stat64 *__restrict __buf)
  ;      __THROW __nonnull ((1, 2));
  lstat64.l(__file.p-utf8, *__buf.stat64)
EndImport

;}

;{ from /usr/include/asm-generic/errno-base.h
#ENOENT = 2  ; No such file Or directory
#ESRCH  = 3  ; No such process
#EBADF  = 9  ; Bad file number
#EPERM  = 1  ; Operation Not permitted
#EINTR  = 4  ; Interrupted system call
#EIO    = 5  ; I/O error
#EMFILE = 24 ; Too many open files
#ENFILE = 23 ; File table overflow
#ENOMEM = 12 ; Out of memory
#ERANGE = 34 ; Math result Not representable
             ;}

;{ from /usr/include/pwd.h
Structure passwd
  *pw_name     ; Username.
  *pw_passwd   ; Password.
  pw_uid.uid_t ; User ID.
  pw_gid.gid_t ; Group ID.
  *pw_gecos    ; Real name.
  *pw_dir      ; Home directory.
  *pw_shell    ; Shell program.
EndStructure

ImportC ""
  ; /* Search For an entry With a matching user ID.
  ;
  ;    This function is a possible cancellation point And therefore Not
  ;    marked With __THROW.  */
  ; extern struct passwd *getpwuid (__uid_t __uid);
  getpwuid.i(__uid.uid_t)
  
  ;    extern int getpwuid_r (__uid_t __uid,
  ;              struct passwd *__restrict __resultbuf,
  ;              char *__restrict __buffer, size_t __buflen,
  ;              struct passwd **__restrict __result);
  getpwuid_r.l(__uid.uid_t, *__resultbuf.passwd, *__buffer, __buflen.size_t, *p__result)
EndImport
;}

;{ from /usr/include/grp.h
Structure group
  *gr_name     ; Group name.
  *gr_passwd   ; Password.
  gr_gid.gid_t ; Group ID.
  *p_gr_mem    ; Member list.
EndStructure

ImportC ""
  ; /* Search For an entry With a matching group ID.
  ;
  ;    This function is a possible cancellation point And therefore Not
  ;    marked With __THROW.  */
  ; extern struct group *getgrgid (__gid_t __gid);
  getgrgid.i(__gid.gid_t)
EndImport
;}

;{ Helper functions
Procedure.s Oct(number.i)
  Protected oct.s = ""
  If (number = 0)
    ProcedureReturn "0"
  EndIf
  While number
    oct = Str(number % 8) + oct
    number / 8
  Wend
  ProcedureReturn oct
EndProcedure
Procedure.s getModeString(mode.mode_t)
  Protected perm.s, prot.i, t.s, o.i = mode
  prot = #__S_ISVTX
  Repeat
    If (o & 4) : t = "r" : Else : t = "-" : EndIf
    If (o & 2) : t + "w" : Else : t + "-" : EndIf
    If (mode & prot)
      If (prot = #__S_ISVTX)
        If (o & 1) : t + "t" : Else : t + "T" : EndIf
      Else
        If (o & 1) : t + "s" : Else : t + "S" : EndIf
      EndIf
    Else
      If (o & 1) : t + "x" : Else : t + "-" : EndIf
    EndIf
    o / 8
    perm = t + perm
    prot * 2
  Until prot > #__S_ISUID
  Select mode & #__S_IFMT
    Case #__S_IFDIR: t = "d"
    Case #__S_IFCHR: t = "c"
    Case #__S_IFBLK: t = "b"
    Case #__S_IFREG: t = "-"
    Case #__S_IFIFO: t = "p"
    Case #__S_IFLNK: t = "l"
    Case #__S_IFSOCK: t = "s"
  EndSelect
  ProcedureReturn t + perm
EndProcedure
Procedure.s getUserName(userId.i)
  Protected buflen.size_t = sysconf(#_SC_GETPW_R_SIZE_MAX)
  If (buflen = -1)
    buflen = 256
  EndIf
  Protected pwd.passwd
  Protected *buffer = AllocateMemory(buflen)
  Protected *presult
  
  If (Not *buffer)
    ProcedureReturn "[ENOMEM]"
  EndIf
  
  Protected errno.i, result.s
  
  Repeat
    errno = getpwuid_r(userId, @pwd, *buffer, buflen, @*presult)
    If (errno = 0)
      If (*presult = 0)
        result = "[NOTFOUND]"
      Else
        result = PeekS(pwd\pw_name, -1, #PB_UTF8)
      EndIf
      Break
    ElseIf (errno = #ERANGE)
      buflen * 2
      Protected *t
      *t = ReAllocateMemory(*buffer, buflen)
      If (Not *t)
        result = "[ENOMEM]"
        Break
      EndIf
      *buffer = *t
    Else
      result = "[ERR:" + errno + "]"
      Break
    EndIf
  ForEver
  
  FreeMemory(*buffer)
  
  ProcedureReturn result
EndProcedure
Procedure.s getGroupName(groupId.i)
  Protected *grp.group = getgrgid(groupId)
  
  If (Not *grp)
    ProcedureReturn ""
  EndIf
  
  ProcedureReturn PeekS(*grp\gr_name, -1, #PB_Ascii)
EndProcedure
Procedure.s getFileType(mode.mode_t)
  Select mode & #__S_IFMT
    Case #__S_IFDIR: ProcedureReturn "Verzeichnis"
    Case #__S_IFCHR: ProcedureReturn "Zeichenorientierte Spezialdatei"
    Case #__S_IFBLK: ProcedureReturn "Blockorientierte Spezialdatei"
    Case #__S_IFREG: ProcedureReturn "Normale Datei"
    Case #__S_IFIFO: ProcedureReturn "FIFO"
    Case #__S_IFLNK: ProcedureReturn "symbolische Verknüpfung"
    Case #__S_IFSOCK: ProcedureReturn "Socket"
  EndSelect
EndProcedure
Procedure.i isSpecialFile(mode.mode_t)
  ProcedureReturn Bool(mode & #__S_IFMT & (~#__S_IFREG & ~#__S_IFLNK & ~#__S_IFDIR))
EndProcedure
;}



Define s.stat64, file.s = "/dev/sda"
lstat64(file, @s)
OpenConsole()
PrintN("  Datei: '" + file + "'")
PrintN("  Größe: " + s\st_size + Chr(9) + "Blöcke: " + s\st_blocks + Chr(9) + "EA Block: " + s\st_blksize + "   " + getFileType(s\st_mode))
Print("Gerät: " + Hex(s\st_dev) + "h/" + s\st_dev + "d" + Chr(9) + "Inode: " + s\st_ino + Chr(9) + "Verknüpfungen: " + s\st_nlink)
If (isSpecialFile(s\st_mode))
  PrintN(Chr(9) + "Gerätetyp: " + Str(major(s\st_rdev)) + "," + Str(minor(s\st_rdev)))
Else
  PrintN("")
EndIf
PrintN("Zugriff: (" + RSet(Oct(s\st_mode & $fff), 4, "0") + "/" + getModeString(s\st_mode) + ")" +
       "  Uid: (" + RSet(Str(s\st_uid), 5) + "/" + RSet(getUserName(s\st_uid), 8) + ")" +
       "   Gid: (" + RSet(Str(s\st_gid), 5) + "/" + RSet(getGroupName(s\st_gid), 8) + ")")
PrintN("Zugriff    : " + FormatDate("%yyyy-%mm-%dd %hh:%ii:%ss", s\st_atime) + "." + StrU(s\st_atimensec, #PB_Long))
PrintN("Modifiziert: " + FormatDate("%yyyy-%mm-%dd %hh:%ii:%ss", s\st_mtime) + "." + StrU(s\st_mtimensec, #PB_Long))
PrintN("Geändert   : " + FormatDate("%yyyy-%mm-%dd %hh:%ii:%ss", s\st_ctime) + "." + StrU(s\st_ctimensec, #PB_Long))
Input()
CloseConsole()
