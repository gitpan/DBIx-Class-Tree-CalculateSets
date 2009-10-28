package DBIx::Class::Tree::CalculateSets;

use base qw/DBIx::Class/;

use Carp qw/confess/;

use strict;
use warnings;

__PACKAGE__->mk_classdata (left_column => 'lft');

__PACKAGE__->mk_classdata (right_column => 'rgt');

__PACKAGE__->mk_classdata (root_column => 'root');

__PACKAGE__->mk_classdata (child_relation => 'children');

our $VERSION = '0.03';

sub is_root {
  my ($self) = @_;

  return $self->id == $self->get_column ($self->root_column);
}

sub calculate_sets {
  my ($self) = @_;

  confess "calculate_sets must be called on tree root" unless $self->is_root;

  $self->result_source->schema->txn_do (sub { $self->_traverse_tree (1) });

  return;
}

sub _traverse_tree {
  my ($self,$left) = @_;

  my $right = $left + 1;

  $self->set_column ($self->left_column,$left);

  foreach my $child ($self->search_related ($self->child_relation)->all) {
    $right = $child->_traverse_tree ($right);

    $right++;
  }

  $self->set_column ($self->right_column,$right);

  $self->update;

  return $right;
}

1;

__END__

=pod

=head1 NAME

DBIx::Class::Tree::CalculateSets

=head1 SYNOPSIS

  Better synopsis to come later, look at t/ for now.

=head1 DESCRIPTION

This is a small utility module that lets you calculate nested sets from
an ordinary parent column based tree structure, allowing you to 
trivially search an entire tree path. Note however, that constructing
the search itself is outside the scope of this module.

=head1 METHODS

=head2 left_column

  __PACKAGE__->left_column('lft'); # The default value

=head2 right_column

  __PACKAGE__->right_column('rgt'); # Also the default

=head2 root_column

  __PACKAGE__->root_column('root'); # Yes, 'root' is default

The name of the column storing the id of the root column. Another way
to think of this column is as the id of the tree the current node
belongs to.

=head2 child_relationship

  __PACKAGE__->child_relationship('children'); # Yeah..

The name of the relationship used to find child nodes of the current 
node.

=head2 is_root

  if ($node->is_root) { }

Returns true if the current node is the root node.

=head2 calculate_sets

  $root->calculate_sets;

Populates the left_column and right_column columns of the entire tree
with the correct nested set values.

=head1 AUTHOR

Anders Nor Berle E<lt>berle@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009 Anders Nor Berle

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

=cut

