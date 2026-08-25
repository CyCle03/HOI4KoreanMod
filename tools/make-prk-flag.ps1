# Flag of the People's Republic of Korea (조선인민공화국, Seoul, September 1945).
#
# The PRK was Yo Un-hyong's committees declared as a state, and it flew the
# taegukgi - so this is the taegukgi. The one change is the upper hoist:
# geon, the trigram for heaven and the sovereign, is the one the star takes.
#
# Writes KOR_peoples_republic.tga at 82x52, 41x26 and 10x7:
#
#   pwsh tools/make-prk-flag.ps1 KoreaMod/gfx/flags
#
# A second argument scales the star - 1.0 is what is shipped, larger reads
# sooner at 41x26 but weighs down the hoist corner. Colours and proportions
# are constants below; the .tga files are binary, so this is the only place
# any of it can be changed.

Add-Type -AssemblyName System.Drawing
$ErrorActionPreference = 'Stop'

$SS = 8
$MW = 82
$MH = 52

function C([int]$r, [int]$g, [int]$b) { [System.Drawing.Color]::FromArgb(255, $r, $g, $b) }
function B($col) { New-Object System.Drawing.SolidBrush($col) }

$RED   = C 205 46 58
$BLUE  = C 0 71 160
$WHITE = C 255 255 255
$BLACK = C 20 20 20
$STAR  = C 200 16 46      # a shade deeper than the taegeuk, so it is not read as part of it

function Draw-Taeguk($g, [double]$cx, [double]$cy, [double]$r, [double]$rot) {
    $st = $g.Save()
    $g.TranslateTransform([single]$cx, [single]$cy)
    $g.RotateTransform([single]$rot)
    $br = B $RED
    $bb = B $BLUE
    $d = [single](2 * $r)
    $g.FillPie($br, [single](-$r), [single](-$r), $d, $d, 180, 180)
    $g.FillPie($bb, [single](-$r), [single](-$r), $d, $d, 0, 180)
    $h = $r / 2
    $g.FillEllipse($br, [single](-$r), [single](-$h), [single]$r, [single]$r)
    $g.FillEllipse($bb, [single]0, [single](-$h), [single]$r, [single]$r)
    $br.Dispose()
    $bb.Dispose()
    $g.Restore($st)
}

function Draw-Trigram($g, [double]$cx, [double]$cy, [double]$ang, [double]$len, [double]$thick, [double]$gap, [bool[]]$pattern, $col) {
    $st = $g.Save()
    $g.TranslateTransform([single]$cx, [single]$cy)
    $g.RotateTransform([single]$ang)
    $brush = B $col
    $step = $thick + $gap
    for ($i = 0; $i -lt 3; $i++) {
        $x = ($i - 1) * $step - $thick / 2
        if ($pattern[$i]) {
            $g.FillRectangle($brush, [single]$x, [single](-$len / 2), [single]$thick, [single]$len)
        } else {
            $seg = $len / 3
            $g.FillRectangle($brush, [single]$x, [single](-$len / 2), [single]$thick, [single]$seg)
            $g.FillRectangle($brush, [single]$x, [single]($len / 2 - $seg), [single]$thick, [single]$seg)
        }
    }
    $brush.Dispose()
    $g.Restore($st)
}

function Draw-Star($g, [double]$cx, [double]$cy, [double]$r, $col) {
    $pts = New-Object 'System.Collections.Generic.List[System.Drawing.PointF]'
    for ($i = 0; $i -lt 10; $i++) {
        $rad = if ($i % 2 -eq 0) { $r } else { $r * 0.382 }
        $a = -[Math]::PI / 2 + $i * [Math]::PI / 5
        $pts.Add((New-Object System.Drawing.PointF(
            [single]($cx + $rad * [Math]::Cos($a)),
            [single]($cy + $rad * [Math]::Sin($a)))))
    }
    $brush = B $col
    $g.FillPolygon($brush, $pts.ToArray())
    $brush.Dispose()
}

function Render($g, [double]$w, [double]$h) {
    $g.Clear($WHITE)
    $cx = $w / 2
    $cy = $h / 2
    $r  = 0.25 * $h

    Draw-Taeguk $g $cx $cy $r -33.69

    $len   = 1.55 * $r
    $thick = $len / 8
    $gap   = $thick / 2
    $d     = 2.25 * $r

    # ri, gam, gon keep their corners. geon's is taken by the star.
    $corners = @(
        @(-1,  1, @($true,  $false, $true )),   # ri,  bottom hoist
        @( 1, -1, @($false, $true,  $false)),   # gam, top fly
        @( 1,  1, @($false, $false, $false))    # gon, bottom fly
    )
    foreach ($spec in $corners) {
        $vx = [double]$spec[0] * $w / 2
        $vy = [double]$spec[1] * $h / 2
        $n = [Math]::Sqrt($vx * $vx + $vy * $vy)
        $ux = $vx / $n
        $uy = $vy / $n
        $ang = [Math]::Atan2($uy, $ux) * 180 / [Math]::PI
        Draw-Trigram $g ($cx + $ux * $d) ($cy + $uy * $d) $ang $len $thick $gap ([bool[]]$spec[2]) $BLACK
    }

    $vx = -$w / 2
    $vy = -$h / 2
    $n = [Math]::Sqrt($vx * $vx + $vy * $vy)
    Draw-Star $g ($cx + $vx / $n * $d) ($cy + $vy / $n * $d) (0.92 * $r * $script:StarScale) $STAR
}

function Save-Tga($bmp, [string]$path) {
    $w = $bmp.Width
    $h = $bmp.Height
    $hdr = [byte[]]@(
        0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        ($w -band 0xFF), (($w -shr 8) -band 0xFF),
        ($h -band 0xFF), (($h -shr 8) -band 0xFF),
        32, 8)
    $data = New-Object byte[] ($w * $h * 4)
    $rect = New-Object System.Drawing.Rectangle 0, 0, $w, $h
    $bd = $bmp.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly,
                        [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    try {
        for ($y = 0; $y -lt $h; $y++) {
            $src = [IntPtr]::Add($bd.Scan0, $bd.Stride * ($h - 1 - $y))
            [System.Runtime.InteropServices.Marshal]::Copy($src, $data, $y * $w * 4, $w * 4)
        }
    } finally {
        $bmp.UnlockBits($bd)
    }
    $fs = [System.IO.File]::Create($path)
    $fs.Write($hdr, 0, $hdr.Length)
    $fs.Write($data, 0, $data.Length)
    $fs.Dispose()
}

function Scale-To($master, [int]$w, [int]$h) {
    $bmp = New-Object System.Drawing.Bitmap($w, $h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $ia = New-Object System.Drawing.Imaging.ImageAttributes
    $ia.SetWrapMode([System.Drawing.Drawing2D.WrapMode]::TileFlipXY)
    $dst = New-Object System.Drawing.Rectangle 0, 0, $w, $h
    $g.DrawImage($master, $dst, 0, 0, $master.Width, $master.Height,
                 [System.Drawing.GraphicsUnit]::Pixel, $ia)
    $g.Dispose()
    $ia.Dispose()
    return $bmp
}

$outDir = $args[0]
if (-not $outDir) { throw 'usage: make-prk-flag.ps1 <flag-dir> [star-scale]' }
$script:StarScale = if ($args[1]) { [double]$args[1] } else { 1.0 }

$master = New-Object System.Drawing.Bitmap(($MW * $SS), ($MH * $SS), [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($master)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
Render $g ($MW * $SS) ($MH * $SS)
$g.Dispose()

foreach ($size in @(@(82, 52, ''), @(41, 26, 'medium'), @(10, 7, 'small'))) {
    $dir = if ($size[2] -eq '') { $outDir } else { Join-Path $outDir $size[2] }
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
    $scaled = Scale-To $master $size[0] $size[1]
    Save-Tga $scaled (Join-Path $dir 'KOR_peoples_republic.tga')
    $scaled.Dispose()
}
$master.Dispose()
Write-Output "wrote KOR_peoples_republic (3 sizes) to $outDir"
