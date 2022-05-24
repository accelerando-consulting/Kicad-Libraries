#!/usr/bin/env perl

use Modern::Perl;
use Data::Dumper qw(Dumper);

sub tuple { print ' ('.join(' ', @_).')'; }

sub startend {
    my %args = (@_);
    tuple('start', $args{x1}, $args{y1});
    tuple('end', $args{x2}, $args{y2});
}

sub line {
    my %args = (width=>0.24, layer=>'F.SilkS', @_);
    #print stderr "line: ",Dumper(\%args);

    print("  (fp_line");
    startend(%args);
    tuple('layer', $args{layer});
    tuple('width', $args{width});
    say(")");
}

sub rect {
    my %args = (@_);
    #print stderr "rect: ",Dumper(\%args);
    line(%args, x1=>$args{x1}, y1=>$args{y1}, x2=>$args{x2}, y2=>$args{y1});
    line(%args, x1=>$args{x2}, y1=>$args{y1}, x2=>$args{x2}, y2=>$args{y2});
    line(%args, x1=>$args{x2}, y1=>$args{y2}, x2=>$args{x1}, y2=>$args{y2});
    line(%args, x1=>$args{x1}, y1=>$args{y2}, x2=>$args{x1}, y2=>$args{y1});
}

sub corners {
    my %args = (@_);
    #print stderr "rect: ",Dumper(\%args);
    line(%args, x1=>$args{x1}, y1=>$args{y1}+3, x2=>$args{x1}, y2=>$args{y1});
    line(%args, x1=>$args{x1}, y1=>$args{y1}, x2=>$args{x1}+3, y2=>$args{y1});

    line(%args, x1=>$args{x2}-3, y1=>$args{y1}, x2=>$args{x2}, y2=>$args{y1});
    line(%args, x1=>$args{x2}, y1=>$args{y1}, x2=>$args{x2}, y2=>$args{y2}+3);

    line(%args, x1=>$args{x2}, y1=>$args{y2}-3, x2=>$args{x2}, y2=>$args{y2});
    line(%args, x1=>$args{x2}, y1=>$args{y2}, x2=>$args{x2}-3, y2=>$args{y2});

    line(%args, x1=>$args{x1}+3, y1=>$args{y2}, x2=>$args{x1}, y2=>$args{y2});
    line(%args, x1=>$args{x1}, y1=>$args{y2}, x2=>$args{x1}, y2=>$args{y2}-3);
}


our $width = 17.5;
our $height = 28.7;

sub lines {
    # say ";;; lines go here";
    rect(x1=>-$width/2, y1=>$height/2, x2=>$width/2, y2=>-$height/2, layer=>'F.Fab');
    corners(x1=>-$width/2, y1=>$height/2, x2=>$width/2, y2=>-$height/2, layer=>'F.SilkS');
    rect(x1=>-$width/2-2, y1=>$height/2+2, x2=>$width/2+2,y2=>-$height/2-2, layer=>'F.CrtYd', width=>0.12);
}

sub pad {
    my %args = (type=>'smd', shape=>'rect', width=>3, height=>0.8, layers=>[qw(F.Cu F.Paste F.Mask)], @_);

    print("  (pad $args{number} $args{type} $args{shape}");
    tuple('at', $args{x}, $args{y});
    tuple('size', $args{width}, $args{height});
    tuple('layers', @{$args{layers}});
    say ")";
}

sub padtrain {
    my %args = @_;
    
    my $number = $args{number};
    my $x = $args{x};
    my $y = $args{y};

    for (1..$args{count}) {
	pad(%args, number=>$number, x=>$x, y=>$y);
	$x += $args{step}->[0];
	$y += $args{step}->[1];
	$number+=1;
    }
}

 
sub pads {
    my %horz = (width=>2.0, height=>0.8);
    my %vert = (width=>0.8, height=>2.0);

    padtrain(number=>0, x=>$width/2, y=>$height/2-6.63, step=>[0,-1.27], count=>2, %horz);
    padtrain(number=>2, x=>$width/2, y=>$height/2-6.63-(3*1.27), step=>[0,-1.27], count=>14, %horz);
    padtrain(number=>16, x=>$width/2-1.77, y=>-$height/2, step=>[-1.27,0], count=>12, %vert);
    padtrain(number=>28, x=>-$width/2, y=>-$height/2+1.77, step=>[0, 1.27], count=>14, %horz);
    padtrain(number=>42, x=>-$width/2, y=>$height/2-6.63-1.27, step=>[0,1.27], count=>2, %horz);
}    


say <<EOT;
(module E73-2G4M04S1B (layer F.Cu) (tedit 5FCD861F)
  (fp_text reference REF** (at -0.52 -11.995) (layer F.SilkS)
    (effects (font (size 1 1) (thickness 0.15)))
  )
  (fp_text value E73-2G4M04S1B (at 0.75 11) (layer F.Fab)
    (effects (font (size 1 1) (thickness 0.15)))
  )
EOT
lines();
pads();
say ')'; 


 

