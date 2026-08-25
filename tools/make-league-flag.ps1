# Flag of the Korean Independence League (조선독립동맹, Yan'an 1942).
# Communist in alignment but Korean-nationalist in symbol - which is why the
# taegeuk stays and the star sits beside it rather than replacing it.
#
# Drawn once at 8x and filtered down, so the taegeuk's S survives at 82x52.
#
# Writes KOR_csr.tga and KOR_sov.tga at 82x52, 41x26 and 10x7. To regenerate
# the flags in place:
#
#   pwsh tools/make-league-flag.ps1 KoreaMod/gfx/flags
#
# Colours, proportions and the star's position are all constants below - the
# .tga files are binary, so this script is the only place they can be changed.

Add-Type -AssemblyName System.Drawing
$ErrorActionPreference = 'Stop'

$SS = 8
$MW = 82
$MH = 52

function C([int]$r, [int]$g, [int]$b) { [System.Drawing.Color]::FromArgb(255, $r, $g, $b) }
function B($col) { New-Object System.Drawing.SolidBrush($col) }

$RED   = C 205 46 58     # taegeuk red
$BLUE  = C 0 71 160      # taegeuk blue
$WHITE = C 250 250 248
$FIELD = C 138 20 26     # deeper than the DPRK's scarlet, so the two read apart
$GOLD  = C 245 199 62

# The taegeuk. $rot tilts the dividing axis; -33.69 is the angle of the
# ri-gam diagonal of a 3:2 field, which is what the flag of Korea uses.
function Draw-Taeguk($g, [double]$cx, [double]$cy, [double]$r, [double]$rot) {
    $st = $g.Save()
    $g.TranslateTransform([single]$cx, [single]$cy)
    $g.RotateTransform([single]$rot)

    $br = B $RED
    $bb = B $BLUE
    $d = [single](2 * $r)

    # red above the axis, blue below it
    $g.FillPie($br, [single](-$r), [single](-$r), $d, $d, 180, 180)
    $g.FillPie($bb, [single](-$r), [single](-$r), $d, $d, 0, 180)
    # the S: red reaches down on the hoist side, blue reaches up on the fly side
    $h = $r / 2
    $g.FillEllipse($br, [single](-$r), [single](-$h), [single]$r, [single]$r)
    $g.FillEllipse($bb, [single]0, [single](-$h), [single]$r, [single]$r)

    $br.Dispose()
    $bb.Dispose()
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
    $g.Clear($FIELD)

    # The taeguk is kept on a white disc, pushed toward the fly to leave the
    # hoist for the star. The white ring has to be wide: the taeguk's red and
    # the field's red are both red, and at 10x7 a thin ring closes up and the
    # whole thing turns into one dark blob.
    $cx = 0.605 * $w
    $cy = 0.50 * $h
    $r  = 0.30 * $h

    $disc = B $WHITE
    $pad = 0.105 * $h
    $g.FillEllipse($disc, [single]($cx - $r - $pad), [single]($cy - $r - $pad),
                          [single](2 * ($r + $pad)), [single](2 * ($r + $pad)))
    $disc.Dispose()

    Draw-Taeguk $g $cx $cy $r -33.69
    Draw-Star $g (0.155 * $w) (0.50 * $h) (0.255 * $h) $GOLD
}

# --- output ------------------------------------------------------------------

function Save-Tga($bmp, [string]$path) {
    $w = $bmp.Width
    $h = $bmp.Height
    $hdr = [byte[]]@(
        0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        ($w -band 0xFF), (($w -shr 8) -band 0xFF),
        ($h -band 0xFF), (($h -shr 8) -band 0xFF),
        32, 8)                                   # 32bpp, bottom-left origin
    $data = New-Object byte[] ($w * $h * 4)
    $rect = New-Object System.Drawing.Rectangle 0, 0, $w, $h
    $bd = $bmp.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly,
                        [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    try {
        for ($y = 0; $y -lt $h; $y++) {
            $src = [IntPtr]::Add($bd.Scan0, $bd.Stride * ($h - 1 - $y))   # bottom-up
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
    $ia.SetWrapMode([System.Drawing.Drawing2D.WrapMode]::TileFlipXY)   # no edge halo
    $dst = New-Object System.Drawing.Rectangle 0, 0, $w, $h
    $g.DrawImage($master, $dst, 0, 0, $master.Width, $master.Height,
                 [System.Drawing.GraphicsUnit]::Pixel, $ia)
    $g.Dispose()
    $ia.Dispose()
    return $bmp
}

$outDir = $args[0]
if (-not $outDir) { throw 'usage: make-league-flag.ps1 <flag-dir> [preview-dir]' }

$mw = $MW * $SS
$mh = $MH * $SS
$master = New-Object System.Drawing.Bitmap($mw, $mh, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($master)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
Render $g $mw $mh
$g.Dispose()

foreach ($name in @('KOR_csr', 'KOR_sov')) {
    foreach ($size in @(@(82, 52, ''), @(41, 26, 'medium'), @(10, 7, 'small'))) {
        $dir = if ($size[2] -eq '') { $outDir } else { Join-Path $outDir $size[2] }
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
        $scaled = Scale-To $master $size[0] $size[1]
        Save-Tga $scaled (Join-Path $dir "$name.tga")
        $scaled.Dispose()
    }
}

# Pass -Preview <dir> to also drop the 8x master out as a PNG for eyeballing.
# It does not go in $outDir: that is the mod's flag folder, and the game reads
# everything in there.
$previewDir = $args[1]
if ($previewDir) {
    if (-not (Test-Path $previewDir)) { New-Item -ItemType Directory -Path $previewDir | Out-Null }
    $master.Save((Join-Path $previewDir 'league_master.png'), [System.Drawing.Imaging.ImageFormat]::Png)
}
$master.Dispose()

Write-Output "wrote KOR_csr / KOR_sov (3 sizes each) to $outDir"
