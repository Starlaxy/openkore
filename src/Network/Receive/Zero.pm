#########################################################################
#  OpenKore - Packet Receiveing
#  This module contains functions for Receiveing packets to the server.
#
#  This software is open source, licensed under the GNU General Public
#  License, version 2.
#  Basically, this means that you're allowed to modify and distribute
#  this software. However, if you distribute modified versions, you MUST
#  also distribute the source code.
#  See http://www.gnu.org/licenses/gpl.html for the full license.
########################################################################
# Korea (kRO) # by alisonrag / sctnightcore
# The majority of private servers use eAthena, this is a clone of kRO
package Network::Receive::Zero;
use strict;
use base qw(Network::Receive::ServerType0);
use Log qw(debug);
use Globals;
use Translation;
use I18N qw(bytesToString);
use Utils::DataStructures;

sub new {
	my ($class) = @_;
	my $self = $class->SUPER::new(@_);

	my %packets = (
		'0ADD' => ['item_appeared', 'a4 V v C v2 C2 v C v', [qw(ID nameID type identified x y subx suby amount show_effect effect_type)]],
	);

	$self->{packet_list}{$_} = $packets{$_} for keys %packets;

	my %handlers = qw(
		account_id 0283
		account_server_info 0AC4
		actor_action 08C8
		actor_exists 09FF
		actor_status_active 0984
		cart_items_nonstackable 0A0F
		cart_items_stackable 0993
		character_status 0229
		hotkeys 0A00
		inventory_item_added 0A37
		inventory_items_nonstackable 0A0D
		inventory_items_stackable 0991
		item_appeared 0ADD
		map_changed 0AC7
		map_loaded 02EB
		received_character_ID_and_Map 0AC5
		received_characters 099D
		received_characters_info 082D
		storage_items_nonstackable 0A10
		storage_items_stackable 0995
		sync_received_characters 09A0
	);

	$self->{packet_lut}{$_} = $handlers{$_} for keys %handlers;

	return $self;
}

sub party_users_info {
	my ($self, $args) = @_;
 	return unless Network::Receive::changeToInGameState();

 	$char->{party}{name} = bytesToString($args->{party_name});

	for (my $i = 0; $i < length($args->{playerInfo}); $i += 54) {
		my $ID = substr($args->{playerInfo}, $i, 4);
		if (binFind(\@partyUsersID, $ID) eq "") {
			binAdd(\@partyUsersID, $ID);
		}
		$char->{party}{users}{$ID} = new Actor::Party();
		@{$char->{party}{users}{$ID}}{qw(ID GID name map admin online jobID lv)} = unpack('V V Z24 Z16 C2 v2', substr($args->{playerInfo}, $i, 54));
		$char->{party}{users}{$ID}{name} = bytesToString($char->{party}{users}{$ID}{name});
		$char->{party}{users}{$ID}{admin} = !$char->{party}{users}{$ID}{admin};
		$char->{party}{users}{$ID}{online} = !$char->{party}{users}{$ID}{online};

		debug TF("Party Member: %s (%s)\n", $char->{party}{users}{$ID}{name}, $char->{party}{users}{$ID}{map}), "party", 1;
	}
}

1;