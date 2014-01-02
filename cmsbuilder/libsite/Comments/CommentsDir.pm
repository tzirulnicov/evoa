package CommentsDir;
use strict qw(subs vars);
use utf8;

use CMSBuilder;

our @ISA = qw(CMSBuilder::DBI::Array);

use CMSBuilder::Utils;

sub _add_classes {qw(Comment)}

sub _cname {'Комментарии'}

sub _rpcs {qw(comment_add)}

#———————————————————————————————————————————————————————————————————————————————

sub admin_comments_add_list
{
	my $o = shift;
	
	unless($o->access('a')){ return; }
	
	return '<form action="/srpc/' . $o->papa->myurl . '/admin_comments_add_comment" method="post" onsubmit="ret = ajax_form_send(event,this); this.name.value = \'\'; return ret">Тип:&nbsp;<select name="class">' . join
	(
		'',
		map { '<option value="' . $_ . '">' . $_->cname . '</option>' }
		grep { $o->elem_can_add($_) && !$_->one_instance } cmsb_classes()
	)
	. '</select>&nbsp;название:&nbsp;<input type="text" name="name">&nbsp;<button type="submit">Добавить...</button></form>';
}

sub site_content{
   my $o=shift;
   my $r=shift;
   use Captcha::reCAPTCHA;
   my $c=Captcha::reCAPTCHA->new;
   print '<div class="catalog feedback" style="min-height: 200px; background: url(/i/profile-bg.png) repeat-x #fcfcfc; border: 1px solid #e3e3e3;">
		<img src="/i/profile-lt.png" class="cat_corners" style="left: -1px; top: -1px; display: block;" alt="" />
		<img src="/i/profile.jpg" class="cat_corners" style="right: -2px; top: -1px; display: block;" alt="" />
		<img src="/i/profile-lb.png" class="cat_corners" style="left: -1px; bottom: -1px;" alt="" />
		<img src="/i/profile-rb.png" class="cat_corners" style="right: -1px; bottom: -1px;" alt="" />
		
		<div class="otzivi_block">
			
			<form action="/srpc/'.$o->myurl.'/comment_add" onsubmit="return otzivi_submit(this)" method="post">
				<input type="hidden" name="comments_mode" value="save">
				<input type="text" class="otzivi_name" name="comment_email" value="E-mail" />
				<input type="text" class="otzivi_mail" name="comment_username" value="Ваше имя" />
				

				<textarea name="comment_desc">Ваш отзыв</textarea>';
$c->get_options_setter((theme=>'white'));
print $c->get_html('6LfxpAQAAAAAAMXYoj39PwpsHrViUgR2RvHasXgr');
print '				<table>
					<tr>
						<td><div><label><input type="checkbox" name="comment_emailme" /><span>Оповестить об ответе на e-mail</span></label></div></td>
						<td><input id="comment_submit" type="image" src="/i/comment.png" class="gogo" name="comment_emailme" />
						<img src="/i/indicator.gif" id="comment_indicator" style="display:none"></td>
					</tr>
				</table>
				
				
				
			</form>
			<div class="otzivi">
				<h5>Отзывы</h5>
				<dl id="comments_div">';
=head
if (CGI::param('comments_mode') eq 'save' && CGI::param('comment_desc') &&
	CGI::param('comment_desc') ne 'Ваш отзыв'){

   my $err;
   my $desc=CGI::param('comment_desc');
   $desc=~s/</&lt;/g;
   $desc=~s/>/&gt;/g;
   Encode::_utf8_on($desc);
   foreach my $k($o->get_all){
      $err='Такой отзыв уже существует' if $k->{desc} eq $desc;
   }
   #$err=123;
   if ($err){
      print "<h4 style='color:red'>$err</h4><p style='padding:10px'>";
   } else {
      my $to=Comment->cre();
      $to->{username}=CGI::param('comment_username');
      $to->{email}=CGI::param('comment_email');
      $to->{emailme}=CGI::param('comment_emailme');
      $to->{desc}=$desc;
      $o->elem_paste($to);
      open(FILE,'>>'.$CMSBuilder::Config::path_htdocs.'/comments.txt') or die $!;
      print FILE $o->papa->myurl.": ".$desc."\r\n";
      close(FILE);
      print "Спасибо, ваш отзыв добавлен<p><p style='padding:10px'>";
   }
}
=cut
   print "<dt>Нет отзывов по данному товару</dt>" if !($o->len);
   foreach my $k($o->get_all){
      $k->site_preview;
   }
   print '				</dl>
			</div>
		</div>
	</div>';
}
sub comment_add{
   my $o=shift;
   my $r=shift;
   my $desc;
   print '<div style="font-weight:bold">';
if ($r->{comments_mode} eq 'save' && $r->{comment_desc} &&
        $r->{comment_desc} ne 'Ваш отзыв'){
   my $err;
        use Captcha::reCAPTCHA;
        my $c=Captcha::reCAPTCHA->new;
        my $result = $c->check_answer(
                '6LfxpAQAAAAAABObicIfK0c0ZiFpd0IlxRm7_aaF', $ENV{'REMOTE_ADDR'},
                $r->{recaptcha_challenge_field}, $r->{recaptcha_response_field}
        );
        if (!($result->{is_valid})){
        	$err='Ошибка ! Неверно введё�
� код подтверждения';
        } else {
   $desc=$r->{comment_desc};
   $desc=~s/</&lt;/g;
   $desc=~s/>/&gt;/g;
   Encode::_utf8_on($desc);
   foreach my $k($o->get_all){
      $err='Такой отзыв уже существует' if $k->{desc} eq $desc;
   }
   }
   #$err=123;
   if ($err){
      print "<h4 style='color:red'>$err</h4><p style='padding:10px'>";
   } else {
      my $to=Comment->cre();
      $to->{username}=$r->{comment_username};
      $to->{email}=$r->{comment_email};
      $to->{emailme}=$r->{comment_emailme};
      $to->{desc}=$desc;
      $o->elem_paste($to);
      open(FILE,'>>'.$CMSBuilder::Config::path_htdocs.'/comments.txt') or die "Cannot write file comments.txt: ".$!;
      print FILE $o->papa->myurl.": ".$desc."\r\n";
      close(FILE);
      print "Спасибо, ваш отзыв добавлен<p><p style='padding:10px'>";
   }
} else {
   print "Ошибка при добавлении отзыва, проверьте введённые данные";
}
   print '</div>';
   foreach my $k($o->get_all){
      if ($k->{emailme} && $k->{desc} ne $desc){
         sendmail(
            to => $k->{'email'},
            from    => 'Evoo <'.$o->root->{'email'}.'>',
            subj    => 
		'Поступил новый отзыв по товару: '.
		$o->papa->name(),
            text    => "Вы получили это письмо, поскольку просили нас уведомить о новых отзывов по товару ".$o->papa->name().
		"\n\nТекст отзыва:\n\n".$k->{'desc'}.
		"\n\nС остальными отзывами Вы можете ознакомиться на странице:\n\n".
		"http://$ENV{HTTP_HOST}/".lc($o->papa->myurl).".html",
            ct              => 'text/plain; charset=windows-1251'
         );
      }
      $k->site_preview;
   }
}
1;
