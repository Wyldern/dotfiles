#!/usr/bin/env fish

if not type -q tide
    if not type -q fisher
        echo "!! fisher is not installed, trying to install with brew..."
        brew install fisher; or echo "!! fisher installation failed, please install manually." && exit -1
    end
    fisher install IlanCosman/tide@v6; or echo "!! tide installation failed, please install manually." && exit -1
end

tide configure \
    --auto \
    --style=Rainbow \
    --prompt_colors='True color' \
    --show_time=No \
    --rainbow_prompt_separators=Angled \
    --powerline_prompt_heads=Sharp \
    --powerline_prompt_tails=Flat \
    --powerline_prompt_style='Two lines, character' \
    --prompt_connection=Solid \
    --powerline_right_prompt_frame=No \
    --prompt_connection_andor_frame_color=Dark \
    --prompt_spacing=Sparse \
    --icons='Few icons' \
    --transient=No
