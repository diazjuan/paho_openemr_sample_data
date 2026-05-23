<?php

use OpenEMR\Core\AbstractModuleActionListener;

/**
 * Laminas Module Manager listener for paho_openemr_sample_data.
 *
 * All action handlers are no-op pass-throughs that return $currentActionStatus.
 * The module does not ship any install-time DDL — the bundled sample data SQL
 * is executed on demand from the Configure page when the admin clicks Run.
 *
 * Per OpenEMR Laminas convention, this file declares no namespace; the
 * module's namespace is reported via getModuleNamespace().
 *
 * @package OpenEMR Modules
 * @license GNU General Public License 3
 */

class ModuleManagerListener extends AbstractModuleActionListener
{
    /**
     * @param  string $methodName
     * @param  mixed  $modId
     * @param  string $currentActionStatus
     * @return string Status string on success, or error description.
     */
    public function moduleManagerAction($methodName, $modId, string $currentActionStatus = 'Success'): string
    {
        if (method_exists(self::class, $methodName)) {
            return self::$methodName($modId, $currentActionStatus);
        }

        return "Module action method $methodName does not exist.";
    }

    public static function getModuleNamespace(): string
    {
        return 'OpenEMR\\Modules\\PahoOpenemrSampleData\\';
    }

    public static function initListenerSelf(): ModuleManagerListener
    {
        return new self();
    }

    private function install($modId, $currentActionStatus): mixed
    {
        return $currentActionStatus;
    }

    private function enable($modId, $currentActionStatus): mixed
    {
        return $currentActionStatus;
    }

    private function disable($modId, $currentActionStatus): mixed
    {
        return $currentActionStatus;
    }

    private function unregister($modId, $currentActionStatus): mixed
    {
        return $currentActionStatus;
    }

    private function install_sql($modId, $currentActionStatus): mixed
    {
        return $currentActionStatus;
    }

    private function upgrade_sql($modId, $currentActionStatus): mixed
    {
        return $currentActionStatus;
    }
}
