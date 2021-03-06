package MojoDb::Controller::Table;
use Mojo::Base 'Mojolicious::Controller';

use Try::Tiny;

# This action will render a template
sub show {
  my $self = shift;

  my $table = $self->stash('table');  
  my $rs    = try { $self->app->schema->resultset($table); };
  
  die "Could not load table $table" unless $rs;
   
  my $where = undef;
  my $options = { rows => 25 };
  
  my $columns = ($self->param('columns')) ?
                [split(',', $self->param('columns'))]:
                [$rs->result_source->columns]; 
  
  my $columns_meta;
  for my $col (@$columns) {
    $columns_meta->{$col} = try   { $rs->result_source->column_info($col) }
                            catch { die "Invalid column $col" };  
  }

  my $rows = $rs->search($where, $options);
  
  #if ($self->param('fulltextsearch')) {        
  #  my $aginst = 'vitae';    
  #  $rows = $rows->search_literal('MATCH (content1, content2) AGAINST( ? )', $aginst);
  #}

  #MATCH (title,body)
  #  AGAINST ('+MySQL -YourSQL' IN BOOLEAN MODE);

  $self->stash(
    rows => $rows,
    columns => $columns,
    columns_meta => $columns_meta
  );
    
  $self->render_maybe("table/$table/show") or
    $self->render('table/_default/show');
}

1;
