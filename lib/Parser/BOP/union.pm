#########################################################################
#
#  Implement the Union operand
#

package Parser::BOP::union;
use strict; use vars qw(@ISA);
@ISA = qw(Parser::BOP);

#
#  Check that the two operands are Intervals, Unions,
#    or points of length two (which can be promoted).
#
sub _check {
  my $self = shift;
  return if ($self->checkStrings());
  if ($self->{lop}->{canBeInterval} && $self->{rop}->{canBeInterval}) {
    $self->{type} = Value::Type('Union',2,$Value::Type{number});
    $self->{canBeInterval} = 1;
    foreach my $op ('lop','rop') {
      if ($self->{$op}->type !~ m/^(Interval|Union)$/) {
	$self->{$op} = bless $self->{$op}, 'Parser::List::Interval';
	$self->{$op}->typeRef->{name} = $self->{equation}{context}{parens}{interval}{type};
      }
    }
  } else {$self->Error("Operands of '%s' must be intervals",$self->{bop})}
}


#
#  Make a union of the two operands.
#
sub _eval {shift; Value::Union->new(@_)}

#
#  Make a union of intervals.
#
sub perl {
  my $self = shift; my $parens = shift; my @union = ();
  foreach my $x ($self->makeUnion) {push(@union,$x->perl)}
  my $perl = 'new Value::Union('.join(',',@union).')';
  $perl = '('.$perl.')' if $parens;
  return $perl;
}

#
#  Turn a union into a list of the intervals in the union.
#
sub makeUnion {
  my $self = shift;
  return (
    $self->{lop}{def}{isUnion}? $self->{lop}->makeUnion : $self->{lop},
    $self->{rop}{def}{isUnion}? $self->{rop}->makeUnion : $self->{rop},
  );
}

#########################################################################

1;

